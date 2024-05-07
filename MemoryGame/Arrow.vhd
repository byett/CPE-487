LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Arrow IS
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		red       : OUT STD_LOGIC;
		green     : OUT STD_LOGIC;
		blue      : OUT STD_LOGIC
	);
END Arrow;

ARCHITECTURE Behavioral OF Arrow IS
	CONSTANT size  : INTEGER := 8;
	SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is over current pixel position
	-- current ball position - intitialized to center of screen
	SIGNAL ball_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL ball_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	-- current ball motion - initialized to +4 pixels/frame
	SIGNAL ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000100";
	SIGNAL x_displacement,y_displacement,arrow_direction : STD_LOGIC := '0';
BEGIN
	red <= '1'; -- color setup for red ball on white background
	green <= NOT ball_on;
	blue  <= NOT ball_on;
	-- process to draw ball current pixel address is covered by ball position
	bdraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS
	BEGIN
    IF (arrow_direction = '1') THEN
red <= '1';
    ELSIF (arrow_direction = '2') THEN
    red <= '1';
    -- DO NOTHING
    
    ELSIF (arrow_direction = '3') THEN
    -- DO NOTHING YET
    red <= '1';
    ELSIF (arrow_direction = '4') THEN
    -- DO NOTING YET
    red <= '1';
    ELSE
    -- ur screwed
    red <= '1';
    END IF;
    END PROCESS;

		--IF (pixel_col >= ball_x - size) AND
		 --(pixel_col <= ball_x + size) AND
		--	 (pixel_row >= ball_y - size) AND
		--	 (pixel_row <= ball_y + size) THEN
		--		ball_on <= '1';
	--	ELSE
		--	ball_on <= '0';
		--END IF;	
	
		-- process to move ball once every frame (i.e. once every vsync pulse)

END Behavioral;
