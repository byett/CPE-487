LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY vga_top IS
    PORT (
        clk_in    : IN STD_LOGIC;
        vga_red   : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); --VGA_TOP will be main game governing code
        vga_green : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); -- Must add stuff for the game's access to drawing arrows for pattern part of FSM
        vga_blue  : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        vga_hsync : OUT STD_LOGIC;
        vga_vsync : OUT STD_LOGIC;
       btn_center : IN  STD_LOGIC;
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
    SIGNAL arrow_direction_FSM : INTEGER range 1 to 5; -- Temporary value to input into Arrow portmap's arrow_direction etc.
    SIGNAL color_chosen_FSM : INTEGER range 1 to 3; -- Temporary value to input into Arrow portmap's chosen_color etc.
    TYPE state IS (GAME_OUTPUT_PRESS, GAME_OUTPUT_RELEASE, USER_INPUT_PRESS, USER_INPUT_RELEASE, IDLE); -- State of game
    SIGNAL current_state, next_state : state := IDLE; -- State of game

    -- The good stuff
    SIGNAL rand_reg : std_logic_vector(31 downto 0) := x"12345678";
    SIGNAL random_number : integer range 1 to 4;
    constant MAX_SEQ_LENGTH : integer := 20; -- If you go past this point congrats you broke my game
    type seq_array is array (0 to MAX_SEQ_LENGTH-1) of integer range 1 to 4;
    signal sequence : seq_array := (others => 1); -- Will be working in conjunction with game_index
    signal Manual : seq_array := (2, 3, 4, 1, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3 ,4 ,1, 2, 3, 4);
    signal user_len : integer := 0; -- current user length
    signal user_index : integer := 0; -- current user array index
    signal game_len : integer := 0; -- Current game length
    signal game_index : integer := 0; -- current game array index
    signal display_timer : integer := 0;
    signal reset : STD_LOGIC := '0';
    signal failed : integer := 0;
    COMPONENT Arrow IS
        PORT (
            v_sync      : IN  STD_LOGIC;
            pixel_row   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
            pixel_col   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
            red         : OUT STD_LOGIC;
            green       : OUT STD_LOGIC; -- NEEDS TO BE DONE IN Arrow TO WORK WITH NOT ball_on
            blue        : OUT STD_LOGIC; -- THAT WAS A PAINFUL MISTAKE DOING IT THROUGH s_rgb IN FSM
            color_chosen : IN INTEGER range 1 to 3; -- PRECAUTIONARY GREEN SCREEN IN CASE FSM BREAKS
            arrow_direction : IN INTEGER range 1 to 5 --5th state for no arrow not needed thanks to output_logic
            
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
      -- ALL COMPONENTS ABOVE THIS POINT
BEGIN --BEGIN 
    vga_red(1 DOWNTO 0) <= "00";
    vga_green(1 DOWNTO 0) <= "00"; --REQUIRED TO MAKE RGB WORK
    vga_blue(0) <= '0';
    
    -- Pseudo-random number generator process
--PRNG: process(clk_in, reset)
--begin
--    if reset = '1' then
--        rand_reg <= (others => '0');
--    elsif rising_edge(pxl_clk) then
--        rand_reg <= rand_reg(30 downto 0) & (rand_reg(31) xor rand_reg(3));
--        random_number <= to_integer(unsigned(rand_reg(31 downto 30))) mod 4 + 1;  -- Properly using to_integer and unsigned
--        random_number <= to_integer(unsigned(rand_reg(31 downto 30))) mod 4 + 1;  -- Properly using to_integer and unsigned
--    end if;
--end process;
    
-- THE GAME FSM LOGIC including state transition handling

        MemoryGameRESET : PROCESS (clk_in, reset) -- state machine clock process
		BEGIN
			IF (btn_center = '1' and btn_left = '1' and btn_right = '1') THEN -- reset to known state
				current_state <= IDLE;
				--current_state <= ENTER_ACC;?
			ELSIF rising_edge (clk_in) THEN -- on rising clock edge
			    current_state <= next_state;
			END IF;
		END PROCESS;
		-- state maching combinatorial process
		-- determines output of state machine and next state
		MemoryGameLogic: PROCESS (failed, btn_center, btn_up, btn_down, btn_left, btn_right, color_chosen_FSM, arrow_direction_FSM, MANUAL, game_len, game_index, user_index)
		BEGIN
            color_chosen_FSM <= 3; --Default
            game_len <= 0; -- default
            game_index <= 0;
            user_index <=0;
            --user_len<= 0; -- default
            arrow_direction_FSM <= 5; -- default
            
			CASE current_state IS -- depending on present state...
				WHEN IDLE => -- waiting for next digit in 1st operand entry
                    -- START THE GAME
--                    if btn_center = '1' then -- WILL START GAME
--                    game_len <= 5;    --default 0+1 (Game length is current level array length for user to match)
--                    game_index <= 0;  --default            (Game Index is game_length - 1 after idle allows for extrapolating each iteration of array length as single value)
--                    --user_len <= 0;    --default            (User index handles user inputs up until less than game length, user index 19 is game length 20 or game index 19. Therefore)
--                    user_index <= 0;   --default             (User index must be less than game length - 1, Cannot be less than game index as game index should reset to avoid issues)
--                    next_state <= GAME_OUTPUT_PRESS;
--                    else
--                    next_state <= IDLE;
--                    end if;
-- SHOULDNT MATTER EITHER WAY BUT TOP VERSION BREAKS
                        if btn_center = '1' then -- WILL START GAME
                        game_len <= 5;    --default 0+1 (Game length is current level array length for user to match)
                        game_index <= 0;  --default            (Game Index is game_length - 1 after idle allows for extrapolating each iteration of array length as single value)
                        --user_len <= 0;    --default            (User index handles user inputs up until less than game length, user index 19 is game length 20 or game index 19. Therefore)
                        user_index <= 0;   --default             (User index must be less than game length - 1, Cannot be less than game index as game index should reset to avoid issues)
                        next_state <= GAME_OUTPUT_PRESS;
                        end if;
				WHEN GAME_OUTPUT_PRESS => -- waiting for center button to be pressed
				    if (btn_center = '1') then
				    arrow_direction_FSM <= manual(game_index);--Manual(0)
				    game_index <= game_index + 1;
				    --Show first thingy
				    -- arrow should equal first array(index 0)
				    next_state <= GAME_OUTPUT_RELEASE; -- On press wait for releast
				    else
				    arrow_direction_FSM <= 5; -- On release go to press 
				    next_state <= GAME_OUTPUT_PRESS; -- No press stay here
                    end if;
                    
				WHEN GAME_OUTPUT_RELEASE => -- waiting for center button to be released
                    if (btn_center = '0') and (game_index < game_len) then -- if button released, and more arrows yet to be displayed, goto GAME_OUTPUT_RELEASE
                    next_state <= GAME_OUTPUT_PRESS;
                    elsif (btn_center = '0') and (game_index >= game_len) then -- if button is released, all arrows have been displayed sucessfully, goto USER_INPUT_PRESS
                    game_index <= 0; -- RESET GAME INDEX TO COMPARE TO USER INDEX
                    next_state <= USER_INPUT_PRESS;
                    else -- IF BUTTON NOT RELEASED YET, STAY HERE UNTIL IT IS
                    next_state <= GAME_OUTPUT_RELEASE;
                    end if;
                   
                    --Stop showing arrow once released
                    -- GO BACK TO output press until array displays full array
                    -- then go to user input portion
                    -- increment game_index until it reaches game length meaning finally reached
				WHEN USER_INPUT_PRESS => -- waiting for button ot be released
                    if (btn_up = '1' OR btn_down = '1' OR btn_left = '1' OR btn_right = '1') THEN
                            if (btn_up = '1' and manual(game_index) = 1) or
                               (btn_down = '1' and manual(game_index) = 2) or
                               (btn_left = '1' and manual(game_index) = 3) or
                               (btn_right = '1' and manual(game_index) = 4) then
                               color_chosen_FSM <= 2; --GREEN IS GOOD
                               arrow_direction_FSM <= manual(game_index); -- CAN USE THIS VALUE BECAUSE WE KNOW WE WERE CORRECT
                               
                            else
                               color_chosen_FSM <= 1;
                               arrow_direction_FSM <= manual(game_index); -- simply show the correct arrow, but in red    
                               failed <= 1; -- Necessary to keep wrong red arrow on screen long enough before releasing to enter 
                            end if;
                            user_index <= user_index + 1; --Increments both user and game indicies
                            game_index <= user_index; --user and game index should always equal each other anyways
                            next_state <= USER_INPUT_RELEASE;
                             
                    else
                    arrow_direction_FSM <= 5;
                    next_state <= USER_INPUT_PRESS;
                    end if;
                    -- Display arrow while user input
                    -- must increment user length
                    -- go until user length reaches game length
                    -- CHECK FIRST IF RIGHT, DISPLAY GREEN IF RIGHT RED IF WRONG                
                    
				WHEN USER_INPUT_RELEASE => -- waiting for next digit in 2nd operand
                    -- STOP SHOWING ARROW, OTHER INCREMENT BS
                    if (btn_up = '0' and btn_down = '0' and btn_left = '0' and btn_right = '0') and (failed = 1) THEN -- YOU FAILED GAME RESET
                    arrow_direction_FSM <= 5;
                    next_state <= IDLE;
                    elsif (btn_up = '0' and btn_down = '0' and btn_left = '0' and btn_right = '0') and (user_index < game_len) THEN -- On release and still need more iterations
                    arrow_direction_FSM <= 5;
                    next_state <= USER_INPUT_PRESS;
                    elsif (btn_up = '0' and btn_down = '0' and btn_left = '0' and btn_right = '0') and (user_index >= game_len) THEN -- On release and finished current level stage
                    game_len <= game_len + 1;
                    arrow_direction_FSM <= 5;
                    next_state <= GAME_OUTPUT_PRESS;
                    else
                    next_state <= USER_INPUT_RELEASE;
                    end if;
               WHEN OTHERS       -- BREAKS THE CODE SOMEHOW?
                   next_state <= IDLE;
			END CASE;
			
		END PROCESS;


-- ARROW COMPONENT ACCEPTS INPUTS FROM FSM
    addArrow : Arrow
    PORT MAP(
        arrow_direction => arrow_direction_FSM,
        v_sync    => S_vsync, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col,
        red       => S_red, 
        green     => S_green, -- changed directly in FSM
        blue      => S_blue,
        color_chosen => color_chosen_FSM
    );
--VGA COMPONENT ACCEPTS COLOR FROM FSM
    vga_driver : vga_sync
    PORT MAP(
        --instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in    => S_red, 
        green_in  => S_green, 
        blue_in   => S_blue, 
        red_out   => vga_red(2), 
        green_out => vga_green(2), 
        blue_out  => vga_blue(1), 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync     => vga_hsync, 
        vsync     => S_vsync
    );
    vga_vsync <= S_vsync;
    
    
    clk_wiz_0_inst : clk_wiz_0
    PORT MAP (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );

END Behavioral;
