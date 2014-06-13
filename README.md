# ViewDomsByCons
Glyph script that allows the user to quickly view domains by choosing a connector.

## Options

This script allows the user to quickly select either a single connector or group of connectors and displays all of the domains with edges that contain the selected connector(s) in the specified format.

When the script is run, a GUI will appear that prompts the user with several options. At the top is a toggle button that allows the user to select either a single connector (default) or a group of connectors (when the button is checked). The second option to be specified is the desired display attributes to be applied to the associated domains. When the script is run, the display attributes of all domains are changed to "Wireframe" with only "Boundaries" shown. This reduces the grid to a wireframe automatically, and will re-apply the original display attributes as soon as the script is completed.

Domain Attributes
*None*:   Interior lines of domains are displayed.
*Flat*:   Domains are filled with a solid color, with cell edges marked with black lines.
*Shaded*: Domains are filled with a solid color and shaded depending on their orientation and the relative direction of the light source.
*HiddenLine*: Interior lines of domains are displayed and cells are filled with the background color, making them opaque and obscuring entities lying behind them in the line of sight.

## Instructions
Once the desired options are specified, click "Go" to begin the selection process. The selection process will repeat indefinitely until you select "Cancel" in the selection pane, which brings the GUI back up. To exit, click "Close", at which point the original display attributes will be re-applied.

![ScriptImage](https://raw.github.com/pointwise/ViewDomsByCons/master/GUI.png)

## Disclaimer
Scripts are freely provided. They are not supported products of Pointwise, Inc. Some scripts have been written and contributed by third parties outside of Pointwise's control.

TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, WITH REGARD TO THESE SCRIPTS. TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR INABILITY TO USE THESE SCRIPTS EVEN IF POINTWISE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE FAULT OR NEGLIGENCE OF POINTWISE.
