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
        arrow_direction : IN INTEGER range 1 to 5; -- Fifth integer is for no arrow
        color_chosen    : IN INTEGER range 1 to 3
    );
END Arrow;

ARCHITECTURE Behavioral OF Arrow IS
    CONSTANT size  : INTEGER := 100;
    SIGNAL ball_on : STD_LOGIC :='0'; -- indicates whether ball is over current pixel position
    -- current ball position - initialized to center of screen
    SIGNAL ball_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    SIGNAL ball_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
    SIGNAL red_on, blue_on, green_on : STD_LOGIC := '1';
	BEGIN 	-- Behav start
	
	
	red <= (NOT ball_on) AND (red_on);
	green <= (NOT ball_on) AND (green_on);
	blue <= (NOT ball_on) AND (blue_on);
    --red <= (red_on);
    --green <= (green_on);
    --blue <= (blue_on);
	
	arrow_draw : PROCESS (ball_x, ball_y, pixel_row, pixel_col, arrow_direction, color_chosen, ball_on) IS
	BEGIN
	--ball_on <= '0';
	
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
	            ball_on <= '0'; -- NO ARROW DICTATED BY INTEGER 5
	        END IF;
    ELSE
    ball_on <= '0'; 
    END IF;
    
    --Case stuff?
    CASE color_chosen IS
            WHEN 1 =>
                red_on <= '1';
                green_on <= '0';
                blue_on <= '0';
            WHEN 2 =>
                red_on <= '0';
                green_on <= '1';
                blue_on <= '0';
            WHEN 3 =>
                red_on <= '0';
                green_on <= '0';
                blue_on <= '1';
        END CASE;
    
    END PROCESS;
   --red_on <= ball_on WHEN color_chosen = 1;
   --blue_on <= ball_on WHEN color_chosen = 2;
   --green_on <= ball_on WHEN color_chosen = 3;
    

END Behavioral;
