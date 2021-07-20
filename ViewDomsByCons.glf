#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################
#
# ----------------------------------------------------------------------
# A Pointwise script which enables the rapid inspection of domains
# based on the selection of connectors.
#
# ----------------------------------------------------------------------
# Concept by Paul Ferlemann
# Programming by Pointwise staff
# ----------------------------------------------------------------------
#
# Load Pointwise Glyph package.
package require PWI_Glyph 2

# Load Tk package.
pw::Script loadTk

# ----------------------------------------------------------------------
# Global variables

set FillTypeMenu ""

# User default preference: 0 = single selection, 1 = multiple selection
set opt(selectMultiple) 0
# User domain fill mode default preference (select from list)
set opt(fillModeCurrentValue) "Shaded"
set opt(menuAllModes) [list None Flat Shaded HiddenLine]

# ----------------------------------------------------------------------
# Widget hierarchy
set w(MainFrame)                 .main
  set w(ConnectorFrame)          $w(MainFrame).fconnector
    set w(SelectionButton)       $w(ConnectorFrame).bselection
  set w(DomainFrame)             $w(MainFrame).fdomain
    set w(ComboboxLabel)         $w(DomainFrame).lcombobox
    set w(ComboboxMenu)          $w(DomainFrame).mcombobox
  set w(Messages)                $w(MainFrame).message
  set w(ButtonsFrame)            $w(MainFrame).buttons
    set w(Logo)                  $w(ButtonsFrame).logo
    set w(ButtonGo)              $w(ButtonsFrame).bgo
    set w(ButtonClose)           $w(ButtonsFrame).bclose

# ----------------------------------------------------------------------
proc makeWindow { } {
  global w
  global opt
  global FillTypeMenu

  frame $w(MainFrame)

    labelframe $w(ConnectorFrame) -text "Connectors"
      checkbutton $w(SelectionButton) -variable opt(selectMultiple) \
        -state normal -text {Select Multiple Connectors?}

    labelframe $w(DomainFrame) -text "Domain Attributes"
      label $w(ComboboxLabel) -text "Fill Mode" -anchor e -width 10
      set FillTypeMenu [ttk::combobox $w(ComboboxMenu) -textvariable \
        opt(fillModeCurrentValue) -values $opt(menuAllModes) -width 10 \
        -state readonly]

    frame $w(ButtonsFrame)
      label $w(Logo) -image [cadenceLogo] -bd 0 -relief flat
      button $w(ButtonGo) -text "Go" -command ViewDomsbyCons -width 5
      button $w(ButtonClose) -text "Close" -command { RevertDisplay; exit } \
        -width 5

  # Main frame
  pack $w(MainFrame) -side top -fill both -expand 1

  # Connector frame
  pack $w(ConnectorFrame) -side top -fill both -pady 5 -padx 5
  pack $w(SelectionButton) -pady 5

  # Domain frame
  pack $w(DomainFrame) -side top -fill both -pady 5 -padx 5
  grid $w(ComboboxLabel) -row 0 -column 0 -sticky e -pady 5 -padx 5
  grid $FillTypeMenu -row 0 -column 1 -sticky ew -pady 5 -padx 2

  label $w(Messages) -text \
    "Click \"Cancel\" to exit selection mode,\n \
     then \"Interrupt Script\" to preserve current view \n \
     or \"Close\" to revert to original view."
  pack $w(Messages)

  # Logo, go and close buttons
  pack $w(ButtonsFrame) -side bottom -pady 5 -padx 5 -fill x
  pack $w(Logo) -side left
  pack $w(ButtonGo) -side left -padx 25
  pack $w(ButtonClose) -side right

  bind . <Control-Key-f> { $w(ButtonGo) invoke }

  # Set the window size and position
  update
  wm geometry . [winfo width .]x[winfo height .]+250+100

  # Set window title
  wm title . "View Domains by Connector"
  wm resizable . 0 0

  raise .
}

# ----------------------------------------------------------------------
# Change display of all domains to wireframe and boundary only,
# after saving original display attributes
proc StoreDisplay {} {
  global domStatus
  set allDoms [pw::Grid getAll -type pw::Domain]
  foreach dom $allDoms {
    set domStatus($dom) [list [$dom getRenderAttribute LineMode] \
        [$dom getRenderAttribute FillMode]]
    $dom setRenderAttribute LineMode Boundary
    $dom setRenderAttribute FillMode None
  }
  pw::Display update
}

# ----------------------------------------------------------------------
# Revert display of all domains to original settings
proc RevertDisplay {} {
  global domStatus
  set allDoms [pw::Grid getAll -type pw::Domain]
  foreach dom $allDoms {
    $dom setRenderAttribute LineMode [lindex $domStatus($dom) 0]
    $dom setRenderAttribute FillMode [lindex $domStatus($dom) 1]
  }
  pw::Display update
}

# ----------------------------------------------------------------------
# Hide domains without saving
proc HideDoms {} {
  set allDoms [pw::Grid getAll -type pw::Domain]
  foreach dom $allDoms {
    $dom setRenderAttribute LineMode Boundary
    $dom setRenderAttribute FillMode None
  }
  pw::Display update
}

# ----------------------------------------------------------------------
# Show only specified domains using selected FillMode preference
proc ShowDoms {doms} {
  global opt
  foreach dom $doms {
    $dom setRenderAttribute LineMode All
    $dom setRenderAttribute FillMode $opt(fillModeCurrentValue)
  }
  pw::Display update
}

# ----------------------------------------------------------------------
# Connector selection
proc selectCon {} {
  global opt
  set conMask [pw::Display createSelectionMask -requireConnector {InDomain}]
  if {$opt(selectMultiple)} {
    set text1 "Select connectors."
    pw::Display selectEntities -description $text1 \
        -selectionmask $conMask curSelection
  } else {
    set text1 "Select a connector."
    pw::Display selectEntities -description $text1 \
        -selectionmask $conMask -single curSelection
  }
  return $curSelection(Connectors)
}

# ----------------------------------------------------------------------
# View domains used by selected connnectors
proc ViewDomsbyCons {} {

  # Store the window position
  set winInfo [winfo geometry .]

  # Withdraw window
  wm withdraw .

  set con [selectCon]
  # Return control to tkwindow if no selection (user hit Cancel)
  if {$con==""} {
    # Restore the window position
    wm geometry . $winInfo
    wm deiconify .
    return
  }
  set existDoms [pw::Domain getDomainsFromConnectors $con]

  # Write connector and domain lists to messages panel
  puts $con
  puts $existDoms
  HideDoms
  ShowDoms $existDoms

  # Recursively call this procedure to continuously be in selection mode
  ViewDomsbyCons
}

# ----------------------------------------------------------------------
# Cadence Design Systems logo
proc cadenceLogo {} {
  set logoData "
R0lGODlhgAAYAPQfAI6MjDEtLlFOT8jHx7e2tv39/RYSE/Pz8+Tj46qoqHl3d+vq62ZjY/n4+NT
T0+gXJ/BhbN3d3fzk5vrJzR4aG3Fubz88PVxZWp2cnIOBgiIeH769vtjX2MLBwSMfIP///yH5BA
EAAB8AIf8LeG1wIGRhdGF4bXD/P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIe
nJlU3pOVGN6a2M5ZCI/PiA8eDp4bXBtdGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1w
dGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYxIDY0LjE0MDk0OSwgMjAxMC8xMi8wNy0xMDo1Nzo
wMSAgICAgICAgIj48cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudy5vcmcvMTk5OS8wMi
8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmY6YWJvdXQ9IiIg/3htbG5zO
nhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0
cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUcGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh
0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0idX
VpZDoxMEJEMkEwOThFODExMUREQTBBQzhBN0JCMEIxNUM4NyB4bXBNTTpEb2N1bWVudElEPSJ4b
XAuZGlkOkIxQjg3MzdFOEI4MTFFQjhEMv81ODVDQTZCRURDQzZBIiB4bXBNTTpJbnN0YW5jZUlE
PSJ4bXAuaWQ6QjFCODczNkZFOEI4MTFFQjhEMjU4NUNBNkJFRENDNkEiIHhtcDpDcmVhdG9yVG9
vbD0iQWRvYmUgSWxsdXN0cmF0b3IgQ0MgMjMuMSAoTWFjaW50b3NoKSI+IDx4bXBNTTpEZXJpZW
RGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MGE1NjBhMzgtOTJiMi00MjdmLWE4ZmQtM
jQ0NjMzNmNjMWI0IiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjBhNTYwYTM4LTkyYjItNDL/
N2YtYThkLTI0NDYzMzZjYzFiNCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g
6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgH//v38+/r5+Pf29fTz8vHw7+7t7Ovp6Ofm5e
Tj4uHg397d3Nva2djX1tXU09LR0M/OzczLysnIx8bFxMPCwcC/vr28u7q5uLe2tbSzsrGwr66tr
KuqqainpqWko6KhoJ+enZybmpmYl5aVlJOSkZCPjo2Mi4qJiIeGhYSDgoGAf359fHt6eXh3dnV0
c3JxcG9ubWxramloZ2ZlZGNiYWBfXl1cW1pZWFdWVlVUU1JRUE9OTUxLSklIR0ZFRENCQUA/Pj0
8Ozo5ODc2NTQzMjEwLy4tLCsqKSgnJiUkIyIhIB8eHRwbGhkYFxYVFBMSERAPDg0MCwoJCAcGBQ
QDAgEAACwAAAAAgAAYAAAF/uAnjmQpTk+qqpLpvnAsz3RdFgOQHPa5/q1a4UAs9I7IZCmCISQwx
wlkSqUGaRsDxbBQer+zhKPSIYCVWQ33zG4PMINc+5j1rOf4ZCHRwSDyNXV3gIQ0BYcmBQ0NRjBD
CwuMhgcIPB0Gdl0xigcNMoegoT2KkpsNB40yDQkWGhoUES57Fga1FAyajhm1Bk2Ygy4RF1seCjw
vAwYBy8wBxjOzHq8OMA4CWwEAqS4LAVoUWwMul7wUah7HsheYrxQBHpkwWeAGagGeLg717eDE6S
4HaPUzYMYFBi211FzYRuJAAAp2AggwIM5ElgwJElyzowAGAUwQL7iCB4wEgnoU/hRgIJnhxUlpA
SxY8ADRQMsXDSxAdHetYIlkNDMAqJngxS47GESZ6DSiwDUNHvDd0KkhQJcIEOMlGkbhJlAK/0a8
NLDhUDdX914A+AWAkaJEOg0U/ZCgXgCGHxbAS4lXxketJcbO/aCgZi4SC34dK9CKoouxFT8cBNz
Q3K2+I/RVxXfAnIE/JTDUBC1k1S/SJATl+ltSxEcKAlJV2ALFBOTMp8f9ihVjLYUKTa8Z6GBCAF
rMN8Y8zPrZYL2oIy5RHrHr1qlOsw0AePwrsj47HFysrYpcBFcF1w8Mk2ti7wUaDRgg1EISNXVwF
lKpdsEAIj9zNAFnW3e4gecCV7Ft/qKTNP0A2Et7AUIj3ysARLDBaC7MRkF+I+x3wzA08SLiTYER
KMJ3BoR3wzUUvLdJAFBtIWIttZEQIwMzfEXNB2PZJ0J1HIrgIQkFILjBkUgSwFuJdnj3i4pEIlg
eY+Bc0AGSRxLg4zsblkcYODiK0KNzUEk1JAkaCkjDbSc+maE5d20i3HY0zDbdh1vQyWNuJkjXnJ
C/HDbCQeTVwOYHKEJJwmR/wlBYi16KMMBOHTnClZpjmpAYUh0GGoyJMxya6KcBlieIj7IsqB0ji
5iwyyu8ZboigKCd2RRVAUTQyBAugToqXDVhwKpUIxzgyoaacILMc5jQEtkIHLCjwQUMkxhnx5I/
seMBta3cKSk7BghQAQMeqMmkY20amA+zHtDiEwl10dRiBcPoacJr0qjx7Ai+yTjQvk31aws92JZ
Q1070mGsSQsS1uYWiJeDrCkGy+CZvnjFEUME7VaFaQAcXCCDyyBYA3NQGIY8ssgU7vqAxjB4EwA
DEIyxggQAsjxDBzRagKtbGaBXclAMMvNNuBaiGAAA7"

  return [image create photo -format GIF -data $logoData]
}

# ----------------------------------------------------------------------
# Main script body

makeWindow
StoreDisplay
tkwait window .

#############################################################################
#
# This file is licensed under the Cadence Public License Version 1.0 (the
# "License"), a copy of which is found in the included file named "LICENSE",
# and is distributed "AS IS." TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE
# LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO
# ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE.
# Please see the License for the full text of applicable terms.
#
#############################################################################
