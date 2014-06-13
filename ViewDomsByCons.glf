#
# This sample Glyph script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
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
      label $w(Logo) -image [pwLogo] -bd 0 -relief flat
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
# Pointwise logo
proc pwLogo {} {
  set logoData "
R0lGODlheAAYAIcAAAAAAAICAgUFBQkJCQwMDBERERUVFRkZGRwcHCEhISYmJisrKy0tLTIyMjQ0
NDk5OT09PUFBQUVFRUpKSk1NTVFRUVRUVFpaWlxcXGBgYGVlZWlpaW1tbXFxcXR0dHp6en5+fgBi
qQNkqQVkqQdnrApmpgpnqgpprA5prBFrrRNtrhZvsBhwrxdxsBlxsSJ2syJ3tCR2siZ5tSh6tix8
ti5+uTF+ujCAuDODvjaDvDuGujiFvT6Fuj2HvTyIvkGKvkWJu0yUv2mQrEOKwEWNwkaPxEiNwUqR
xk6Sw06SxU6Uxk+RyVKTxlCUwFKVxVWUwlWWxlKXyFOVzFWWyFaYyFmYx16bwlmZyVicyF2ayFyb
zF2cyV2cz2GaxGSex2GdymGezGOgzGSgyGWgzmihzWmkz22iymyizGmj0Gqk0m2l0HWqz3asznqn
ynuszXKp0XKq1nWp0Xaq1Hes0Xat1Hmt1Xyt0Huw1Xux2IGBgYWFhYqKio6Ojo6Xn5CQkJWVlZiY
mJycnKCgoKCioqKioqSkpKampqmpqaurq62trbGxsbKysrW1tbi4uLq6ur29vYCu0YixzYOw14G0
1oaz14e114K124O03YWz2Ie12oW13Im10o621Ii22oi23Iy32oq52Y252Y+73ZS51Ze81JC625G7
3JG825K83Je72pW93Zq92Zi/35G+4aC90qG+15bA3ZnA3Z7A2pjA4Z/E4qLA2KDF3qTA2qTE3avF
36zG3rLM3aPF4qfJ5KzJ4LPL5LLM5LTO4rbN5bLR6LTR6LXQ6r3T5L3V6cLCwsTExMbGxsvLy8/P
z9HR0dXV1dbW1tjY2Nra2tzc3N7e3sDW5sHV6cTY6MnZ79De7dTg6dTh69Xi7dbj7tni793m7tXj
8Nbk9tjl9N3m9N/p9eHh4eTk5Obm5ujo6Orq6u3t7e7u7uDp8efs8uXs+Ozv8+3z9vDw8PLy8vL0
9/b29vb5+/f6+/j4+Pn6+/r6+vr6/Pn8/fr8/Pv9/vz8/P7+/gAAACH5BAMAAP8ALAAAAAB4ABgA
AAj/AP8JHEiwoMGDCBMqXMiwocOHECNKnEixosWLGDNqZCioo0dC0Q7Sy2btlitisrjpK4io4yF/
yjzKRIZPIDSZOAUVmubxGUF88Aj2K+TxnKKOhfoJdOSxXEF1OXHCi5fnTx5oBgFo3QogwAalAv1V
yyUqFCtVZ2DZceOOIAKtB/pp4Mo1waN/gOjSJXBugFYJBBflIYhsq4F5DLQSmCcwwVZlBZvppQtt
D6M8gUBknQxA879+kXixwtauXbhheFph6dSmnsC3AOLO5TygWV7OAAj8u6A1QEiBEg4PnA2gw7/E
uRn3M7C1WWTcWqHlScahkJ7NkwnE80dqFiVw/Pz5/xMn7MsZLzUsvXoNVy50C7c56y6s1YPNAAAC
CYxXoLdP5IsJtMBWjDwHHTSJ/AENIHsYJMCDD+K31SPymEFLKNeM880xxXxCxhxoUKFJDNv8A5ts
W0EowFYFBFLAizDGmMA//iAnXAdaLaCUIVtFIBCAjP2Do1YNBCnQMwgkqeSSCEjzzyJ/BFJTQfNU
WSU6/Wk1yChjlJKJLcfEgsoaY0ARigxjgKEFJPec6J5WzFQJDwS9xdPQH1sR4k8DWzXijwRbHfKj
YkFO45dWFoCVUTqMMgrNoQD08ckPsaixBRxPKFEDEbEMAYYTSGQRxzpuEueTQBlshc5A6pjj6pQD
wf9DgFYP+MPHVhKQs2Js9gya3EB7cMWBPwL1A8+xyCYLD7EKQSfEF1uMEcsXTiThQhmszBCGC7G0
QAUT1JS61an/pKrVqsBttYxBxDGjzqxd8abVBwMBOZA/xHUmUDQB9OvvvwGYsxBuCNRSxidOwFCH
J5dMgcYJUKjQCwlahDHEL+JqRa65AKD7D6BarVsQM1tpgK9eAjjpa4D3esBVgdFAB4DAzXImiDY5
vCFHESko4cMKSJwAxhgzFLFDHEUYkzEAG6s6EMgAiFzQA4rBIxldExBkr1AcJzBPzNDRnFCKBpTd
gCD/cKKKDFuYQoQVNhhBBSY9TBHCFVW4UMkuSzf/fe7T6h4kyFZ/+BMBXYpoTahB8yiwlSFgdzXA
5JQPIDZCW1FgkDVxgGKCFCywEUQaKNitRA5UXHGFHN30PRDHHkMtNUHzMAcAA/4gwhUCsB63uEF+
bMVB5BVMtFXWBfljBhhgbCFCEyI4EcIRL4ChRgh36LBJPq6j6nS6ISPkslY0wQbAYIr/ahCeWg2f
ufFaIV8QNpeMMAkVlSyRiRNb0DFCFlu4wSlWYaL2mOp13/tY4A7CL63cRQ9aEYBT0seyfsQjHedg
xAG24ofITaBRIGTW2OJ3EH7o4gtfCIETRBAFEYRgC06YAw3CkIqVdK9cCZRdQgCVAKWYwy/FK4i9
3TYQIboE4BmR6wrABBCUmgFAfgXZRxfs4ARPPCEOZJjCHVxABFAA4R3sic2bmIbAv4EvaglJBACu
IxAMAKARBrFXvrhiAX8kEWVNHOETE+IPbzyBCD8oQRZwwIVOyAAXrgkjijRWxo4BLnwIwUcCJvgP
ZShAUfVa3Bz/EpQ70oWJC2mAKDmwEHYAIxhikAQPeOCLdRTEAhGIQKL0IMoGTGMgIBClA9QxkA3U
0hkKgcy9HHEQDcRyAr0ChAWWucwNMIJZ5KilNGvpADtt5JrYzKY2t8nNbnrzm+B8SEAAADs="

  return [image create photo -format GIF -data $logoData]
}

# ----------------------------------------------------------------------
# Main script body

makeWindow
StoreDisplay
tkwait window .

#
# END SCRIPT
#
# DISCLAIMER:
# TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
# ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
# TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, WITH REGARD TO THIS SCRIPT.  TO THE MAXIMUM EXTENT PERMITTED
# BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
# FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
# WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF
# BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE
# USE OF OR INABILITY TO USE THIS SCRIPT EVEN IF POINTWISE HAS BEEN
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE
# FAULT OR NEGLIGENCE OF POINTWISE.
#
