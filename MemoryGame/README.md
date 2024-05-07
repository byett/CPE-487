# FINAL PROJECT: MemoryGame
  * Utilizing **Lab 3: Bouncing Ball** code
  * Implement Arrow_UP, Arrow_DOWN, Arrow_LEFT, Arrow_RIGHT portmapping
      * Variables for X and Y displacements
      * IF Statement, calls one of four arrow positions and assigns corresponding displacements


## Whats left to do
  * Generate string of random arrow positions, calls and shows arrows in pattern
  * Accept user inputs and checks for matching arrows, if mismatch found you lose
  * Keep generating longer patterns each time user completes current string of random arrows
  * stuff

## MemoryGame Setup

### 1. Create a new RTL project MemoryGame in Vivado Quick Start

* Create five new source files of file type VHDL called **_clk_wiz_0_**, **_clk_wiz_0_clk_wiz_**, **_vga_sync_**, **_Arrow_**, and **_vga_top_**

* Create a new constraint file of file type XDC called **_vga_top_**

* Choose Nexys A7-100T board for the project

* Click 'Finish'

* Click design sources and copy the VHDL code from clk_wiz_0.vhd, clk_wiz_0_clk_wiz.vhd, vga_sync.vhd, Arrow.vhd, and vga_top.vhd

* Click constraints and copy the code from vga_top.xdc

* As an alternative, you can instead download files from Github and import them into your project when creating the project. The source file or files would still be imported during the Source step, and the constraint file or files would still be imported during the Constraints step.

### 2. Run synthesis

### 3. Run implementation

### 3b. (optional, generally not recommended as it is difficult to extract information from and can cause Vivado shutdown) Open implemented design

### 4. Generate bitstream, open hardware manager, and program device

* Click 'Generate Bitstream'

* Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'

* Click 'Program Device' then xc7a100t_0 to download vga_top.bit to the Nexys A7 board

* Have Fun!

![HAPPY CAT YAY](https://media.tenor.com/lCKwsD2OW1kAAAAj/happy-cat-happy-happy-cat.gif) ![HAPPY CAT YAY](https://media.tenor.com/lCKwsD2OW1kAAAAj/happy-cat-happy-happy-cat.gif) ![HAPPY CAT YAY](https://media.tenor.com/lCKwsD2OW1kAAAAj/happy-cat-happy-happy-cat.gif) ![HAPPY CAT YAY](https://media.tenor.com/lCKwsD2OW1kAAAAj/happy-cat-happy-happy-cat.gif)
