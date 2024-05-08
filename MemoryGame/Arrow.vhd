LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Arrow IS
    PORT (
        v_sync          : IN  STD_LOGIC;
        pixel_row       : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col       : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        red             : OUT STD_LOGIC;
        green           : OUT STD_LOGIC;
        blue            : OUT STD_LOGIC;
        arrow_direction : IN INTEGER range 1 to 4;
        color_chosen    : IN INTEGER range 1 to 3
    );
END Arrow;

ARCHITECTURE Behavioral OF Arrow IS
    CONSTANT size  : INTEGER := 8;
    SIGNAL ball_on : STD_LOGIC :='0'; -- indicates whether ball is over current pixel position
    -- current ball position - initialized to center of screen
    SIGNAL ball_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    SIGNAL ball_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
    
	BEGIN 	-- Behav start
	
    --red <= '1';
    --green <= NOT ball_on;
    --blue <= NOT ball_on;
	
	arrow_draw : PROCESS (ball_x, ball_y, pixel_row, pixel_col, arrow_direction, color_chosen, ball_on) IS
	BEGIN
	ball_on <= '0';
	
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
    ball_on <= '0';
    -- No arrow shows
   
    END IF;
   -- red <= '1';
   -- green <= NOT ball_on;
   -- blue <= NOT ball_on;
    END PROCESS;

END Behavioral;
