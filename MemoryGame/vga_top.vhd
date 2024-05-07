LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY vga_top IS
    PORT (
        clk_in    : IN STD_LOGIC;
        vga_red   : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); --VGA_TOP will be main game governing code
        vga_green : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); -- Must add stuff for the game's access to drawing arrows for pattern part of FSM
        vga_blue  : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        vga_hsync : OUT STD_LOGIC;
        vga_vsync : OUT STD_LOGIC;
        clk       : IN  STD_LOGIC;
        reset     : IN  STD_LOGIC; 
        btn_up    : IN  STD_LOGIC;
        btn_down  : IN  STD_LOGIC;
        btn_left  : IN  STD_LOGIC;
        btn_right : IN  STD_LOGIC
    );
END vga_top;

ARCHITECTURE Behavioral OF vga_top IS
    SIGNAL pxl_clk : STD_LOGIC;
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC; --Will input values for vga_sync's red_in etc.
    SIGNAL S_vsync : STD_LOGIC; --Will input values for vga_sync's vsync_in
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0); -- Same stuff here
    SIGNAL x_displacement_FSM, y_displacement_FSM : INTEGER:=0; -- Temporary value to input into Arrow portmap's x_displacement etc.
    SIGNAL arrow_direction_FSM : INTEGER range 0 to 4:=0; -- Temporary value to input into Arrow portmap's arrow_direction etc.
    TYPE state IS (GAME_OUTPUT, IDLE, SHOW_ARROW, CHECK_INPUT, NEXT_LEVEL); -- State of game
    SIGNAL current_state, next_state : state := IDLE; -- State of game

    COMPONENT Arrow IS
        PORT (
            v_sync      : IN  STD_LOGIC;
            pixel_row   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
            pixel_col   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
            --red         : OUT STD_LOGIC;
            --green       : OUT STD_LOGIC; --red -> s_red not needed anymore
            --blue        : OUT STD_LOGIC; -- done directly from fsm
            x_displacement,y_displacement : IN INTEGER;
            arrow_direction : IN INTEGER range 0 to 4 --5th state for no arrow not needed thanks to output_logic
            
        );
    END COMPONENT;
    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC; 
            green_in  : IN STD_LOGIC;
            blue_in   : IN STD_LOGIC;
            red_out   : OUT STD_LOGIC;
            green_out : OUT STD_LOGIC;
            blue_out  : OUT STD_LOGIC;
            hsync     : OUT STD_LOGIC;
            vsync     : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;
    
    component clk_wiz_0 is
    port (
      clk_in1  : in std_logic;
      clk_out1 : out std_logic
    );
    end component;
    
    
BEGIN
    
	MemoryGameFSM: PROCESS (clk, reset) --current_state/next_state governing
    BEGIN
    IF reset = '1' THEN
                current_state <= GAME_OUTPUT;
            ELSIF rising_edge(clk) THEN
                current_state <= next_state;
            END IF;
        END PROCESS MemoryGameFSM;

        -- Define state transitions and outputs
        MemoryGameLogic: PROCESS (current_state, btn_up, btn_down, btn_left, btn_right) --FSM PURELY FOR USER INPUT, REPEAT FOR GAME INPUT
        
        BEGIN
        
            CASE current_state IS
                WHEN GAME_OUTPUT =>
                    IF
                    --utilize CHECK_INPUT/NEXT_LEVEL states to
                    --Implement random set of pattern integers in array, random values 1-4 for each arrow direction
                    --Display each arrow in a given order with time in between, when done ask for user to repeat
                    --and match with the arrows displayed on the screen, must implement matching system with each button press
                    --Upon achieving this, add to existing pattern that must be matched again
                    --If fail or reset, reset everything
                    --Also maybe try to display score or highest pattern high score and other stuff, lots of work though
                    
                    ELSE
                    current_state <= IDLE;
                WHEN IDLE =>
                    IF btn_up = '1' THEN -- UP BUTTON PRESS
                        arrow_direction_FSM <= 1; -- WILL SET TO arrow_direction IN SHOW ARROW STATE
                        x_displacement_FSM <= 0;
                        y_displacement_FSM <= 100;
                       
                        next_state <= SHOW_ARROW;
                    ELSIF btn_down = '1' THEN -- DOWN BUTTON PRESS
                        arrow_direction_FSM <= 2; -- Down
                        x_displacement_FSM <= 0;
                        y_displacement_FSM <= 200;
                    
                        next_state <= SHOW_ARROW;
                    ELSIF btn_left = '1' THEN -- LEFT BUTTON PRESS
                        arrow_direction_FSM <= 3; -- Left
                        x_displacement_FSM <= 100;
                        y_displacement_FSM <= 100;
                        
                        next_state <= SHOW_ARROW;
                    ELSIF btn_right = '1' THEN -- RIGHT BUTTON PRESS
                        arrow_direction_FSM <= 4; -- Right
                        x_displacement_FSM <= 200;
                        y_displacement_FSM <= 100;
                        
                        next_state <= SHOW_ARROW;
                    ELSE
                        next_state <= IDLE;
                    END IF;
                WHEN SHOW_ARROW =>
                    
                    
                    
                    
                    -- Logic to display arrow based on `arrow_direction`
                    -- Transition to CHECK_INPUT or directly to IDLE after a delay or a condition
                    next_state <= CHECK_INPUT;
                WHEN CHECK_INPUT =>
                    -- Check if the correct button is pressed, transition to NEXT_LEVEL or back to IDLE
                    next_state <= NEXT_LEVEL;
                WHEN NEXT_LEVEL =>
                    -- Prepare the next level, potentially increase difficulty
                    next_state <= IDLE;
            END CASE;
        END PROCESS MemoryGameLogic;

        -- Output logic based on the state
        output_logic: PROCESS (current_state)
        BEGIN
            CASE current_state IS
                WHEN SHOW_ARROW =>
                S_red <= '0'; 
                S_green <= '0';
                S_blue <= '1';
                WHEN OTHERS =>
                S_red <= '0';
                S_green <= '0'; --NO ARROW DRAWN
                S_blue <= '0';
            END CASE;
        END PROCESS output_logic;
        
    addArrow : Arrow
    PORT MAP(
        x_displacement => x_displacement_FSM,
        y_displacement => y_displacement_FSM,
        arrow_direction => arrow_direction_FSM,
        v_sync    => S_vsync, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col
        --red       => S_red, 
        --green     => S_green, 
        --blue      => S_blue
    );
   
    vga_driver : vga_sync
    PORT MAP(
        --instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in    => S_red, --From FSM
        green_in  => S_green, --From FSM
        blue_in   => S_blue, --From FSM
        red_out   => vga_red(2), 
        green_out => vga_green(2), 
        blue_out  => vga_blue(1), 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync     => vga_hsync, 
        vsync     => S_vsync
    );
    vga_vsync <= S_vsync; --connect output vsync
        
    clk_wiz_0_inst : clk_wiz_0
    port map (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );
    
END Behavioral;
