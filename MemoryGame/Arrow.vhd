LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Arrow IS
	PORT (
        v_sync      : IN  STD_LOGIC;
        pixel_row   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        --red         : OUT STD_LOGIC;
        --green       : OUT STD_LOGIC; --DONE IN vga_top
        --blue        : OUT STD_LOGIC;
        arrow_direction : IN INTEGER range 1 to 4
	);
END Arrow;

ARCHITECTURE Behavioral OF Arrow IS
	CONSTANT size  : INTEGER := 8;
	SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is over current pixel position
	-- current ball position - intitialized to center of screen
	SIGNAL ball_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL ball_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	-- current ball motion - initialized to +4 pixels/frame
	SIGNAL ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000000";
	
	BEGIN 	-- Behav start
	arrow_draw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS
	BEGIN

	-- process to draw ball current pixel address is covered by ball position
   IF (arrow_direction = 1) THEN
            IF (pixel_col >= ball_x AND
                pixel_row <= ball_y AND
                pixel_row >= ball_y + (pixel_col - ball_x) - size) THEN
                       ball_on <= '1';
            ELSIF (pixel_col <= ball_x AND
                   pixel_row <= ball_y AND
                   pixel_row >= ball_y + (ball_x - pixel_col) - size) THEN
                        ball_on <= '1';
            ELSIF (pixel_col >= ball_x - size/2) AND
                  (pixel_col <= ball_x + size/2) AND
                  (CONV_INTEGER(pixel_row) >= CONV_INTEGER(ball_y)+60 - size) AND
                  (CONV_INTEGER(pixel_row) <= CONV_INTEGER(ball_y)+60 + size) THEN
                        ball_on <= '1';
            ELSE
                ball_on <= '0';
            END IF;
    ELSIF (arrow_direction = 2) THEN --DOWN ARROW
            IF (pixel_col >= ball_x AND
            	pixel_row >= ball_y AND
            	pixel_row <= ball_y - (pixel_col - ball_x) + size) THEN
                	ball_on <= '1';
            ELSIF (pixel_col <= ball_x AND
            	   pixel_row >= ball_y AND
            	   pixel_row <= ball_y - (ball_x - pixel_col) + size) THEN
                	ball_on <= '1';
            ELSIF (pixel_col >= ball_x - size/2) AND
              	  (pixel_col <= ball_x + size/2) AND
              	  (CONV_INTEGER(pixel_row) >= CONV_INTEGER(ball_y)-60 - size) AND
              	  (CONV_INTEGER(pixel_row) <= CONV_INTEGER(ball_y)-60 + size) THEN
                    	ball_on <= '1';
            ELSE
            	ball_on <= '0';
            END IF;
    ELSIF (arrow_direction = 3) THEN --LEFT ARROW
    	    IF (pixel_col <= ball_x AND
            	pixel_row >= ball_y AND
            	pixel_row <= ball_y + (pixel_col - ball_x) + size) THEN
                	ball_on <= '1';
            ELSIF (pixel_col <= ball_x AND
                   pixel_row <= ball_y AND
                   pixel_row >= ball_y - (pixel_col - ball_x) - size) THEN
                       ball_on <= '1';
            ELSIF (pixel_col >= (ball_x+60) - size) AND
              	  (pixel_col <= (ball_x+60) + size) AND
              	  (pixel_row >= ball_y - size/2) AND
              	  (pixel_row <= ball_y + size/2) THEN
                    	ball_on <= '1';
            ELSE
            	ball_on <= '0';
            END IF;
    ELSIF (arrow_direction = 4) THEN --RIGHT ARROW
	        IF (pixel_col >= ball_x AND
	            pixel_row <= ball_y AND
	            pixel_row >= ball_y - (ball_x - pixel_col) - size) THEN
	                ball_on <= '1';
	        ELSIF (pixel_col >= ball_x AND
	               pixel_row >= ball_y AND
	               pixel_row <= ball_y + (ball_x - pixel_col) + size) THEN
	                    ball_on <= '1';
	        ELSIF (pixel_col >= (ball_x-60) - size) AND
	              (pixel_col <= (ball_x-60) + size) AND
	              (pixel_row >= ball_y - size/2) AND
	              (pixel_row <= ball_y + size/2) THEN
	                    ball_on <= '1';
	        ELSE
	            ball_on <= '0';
	        END IF;
    ELSE
    -- No arrow shows
   
    END IF;
    END PROCESS;

END Behavioral;
