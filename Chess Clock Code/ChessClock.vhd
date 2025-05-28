library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ChessClock is
    Port (
        CLOCK_50 : in STD_LOGIC;
        KEY : in STD_LOGIC_VECTOR(3 downto 0);
        SW0 : in STD_LOGIC;
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out STD_LOGIC_VECTOR(6 downto 0);
        LEDR : out STD_LOGIC_VECTOR(0 downto 0)
    );
end ChessClock;

architecture Behavioral of ChessClock is
    -- Clock divider for 1Hz pulse
    signal sec_counter : integer range 0 to 49_999_999 := 0;
    signal one_sec_pulse : STD_LOGIC := '0';

    -- Player time (minutes and seconds)
    signal minutes_p1, seconds_p1 : integer range 0 to 59 := 1;
    signal minutes_p2, seconds_p2 : integer range 0 to 59 := 1;

    -- Current player indicator ('1' = Player 1, '0' = Player 2)
    signal current_player : STD_LOGIC := '1';
    signal running : STD_LOGIC := '0';

    -- Debounce signals for Keys 2 and 3
    signal key2_last_state, key3_last_state : STD_LOGIC := '1';
    signal key2_debounced, key3_debounced : STD_LOGIC := '1';
    signal debounce_counter_2, debounce_counter_3 : integer range 0 to 500000 := 0;

    -- Function to encode BCD for 7-segment display
    function BCD_Encoder(num : integer) return STD_LOGIC_VECTOR is
        variable bcd : STD_LOGIC_VECTOR(6 downto 0);
    begin
        case num is
            when 0 => bcd := "1000000"; -- 0
            when 1 => bcd := "1111001"; -- 1
            when 2 => bcd := "0100100"; -- 2
            when 3 => bcd := "0110000"; -- 3
            when 4 => bcd := "0011001"; -- 4
            when 5 => bcd := "0010010"; -- 5
            when 6 => bcd := "0000010"; -- 6
            when 7 => bcd := "1111000"; -- 7
            when 8 => bcd := "0000000"; -- 8
            when 9 => bcd := "0010000"; -- 9
            when others => bcd := "1111111"; -- Blank
        end case;
        return bcd;
    end function;

begin
    -- Clock Divider: Generates 1Hz pulse
    process (CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            if sec_counter = 49_999_999 then
                sec_counter <= 0;
                one_sec_pulse <= '1';
            else
                sec_counter <= sec_counter + 1;
                one_sec_pulse <= '0';
            end if;
        end if;
    end process;

    -- Debounce Process for Key 2 (Switch Player)
    process (CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            if KEY(2) = '0' then
                if debounce_counter_2 < 500000 then
                    debounce_counter_2 <= debounce_counter_2 + 1;
                else
                    key2_debounced <= '0';
                end if;
            else
                debounce_counter_2 <= 0;
                key2_debounced <= '1';
            end if;
        end if;
    end process;

    -- Debounce Process for Key 3 (Increase Time)
    process (CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            if KEY(3) = '0' then
                if debounce_counter_3 < 500000 then
                    debounce_counter_3 <= debounce_counter_3 + 1;
                else
                    key3_debounced <= '0';
                end if;
            else
                debounce_counter_3 <= 0;
                key3_debounced <= '1';
            end if;
        end if;
    end process;

   -- IDLE STATE, Timer setup and Control Logic
process (CLOCK_50)
begin
    if rising_edge(CLOCK_50) then
        -- Reset Logic (Key 0)
        if KEY(0) = '0' then
            running <= '0';  -- Stop the clock

            if SW0 = '0' then  -- Game Mode 1
                minutes_p1 <= 1;
                seconds_p1 <= 0;
                minutes_p2 <= 1;
                seconds_p2 <= 0;
            else  -- Game Mode 2
                minutes_p1 <= 0;
                seconds_p1 <= 15;
                minutes_p2 <= 0;
                seconds_p2 <= 15;
            end if;

            current_player <= '1';  -- Start with Player 1
        end if;

        -- Play Button (Key 1)
        if KEY(1) = '0' then
            running <= '1';
        end if;
		  
		  

        -- Switch Player (Key 2) - Works in Both Modes
        if key2_debounced = '0' and key2_last_state = '1' and running = '1' then
            current_player <= not current_player;  -- Toggle Player

            -- In Game Mode 2 (SW0 = 1), add 5 seconds when switching
            if SW0 = '1' then
                if current_player = '1' then
                    if seconds_p1 <= 54 then
                        seconds_p1 <= seconds_p1 + 5;
                    else
                        if minutes_p1 < 59 then
                            minutes_p1 <= minutes_p1 + 1;
                            seconds_p1 <= (seconds_p1 + 5) - 60;
                        else
                            seconds_p1 <= 59;  -- Cap at 59 seconds if maxed out
                        end if;
                    end if;
                else
                    if seconds_p2 <= 54 then
                        seconds_p2 <= seconds_p2 + 5;
                    else
                        if minutes_p2 < 59 then
                            minutes_p2 <= minutes_p2 + 1;
                            seconds_p2 <= (seconds_p2 + 5) - 60;
                        else
                            seconds_p2 <= 59;  -- Cap at 59 seconds if maxed out
                        end if;
                    end if;
                end if;
            end if;
        end if;
        key2_last_state <= key2_debounced;



        -- Countdown State
        if running = '1' and one_sec_pulse = '1' then
            if current_player = '1' then
                if seconds_p1 = 0 then
                    if minutes_p1 > 0 then
                        minutes_p1 <= minutes_p1 - 1;
                        seconds_p1 <= 59;
                    end if;
                else
                    seconds_p1 <= seconds_p1 - 1;
                end if;
            else
                if seconds_p2 = 0 then
                    if minutes_p2 > 0 then
                        minutes_p2 <= minutes_p2 - 1;
                        seconds_p2 <= 59;
                    end if;
                else
                    seconds_p2 <= seconds_p2 - 1;
                end if;
            end if;
        end if;
    end if;
end process;


    -- Display Logic
    HEX5 <= "0001100";  -- 'P' for player indicator
    HEX4 <= BCD_Encoder(1) when current_player = '1' else BCD_Encoder(2);
    HEX3 <= BCD_Encoder((minutes_p1 / 10) mod 10) when current_player = '1' else BCD_Encoder((minutes_p2 / 10) mod 10);
    HEX2 <= BCD_Encoder(minutes_p1 mod 10) when current_player = '1' else BCD_Encoder(minutes_p2 mod 10);
    HEX1 <= BCD_Encoder((seconds_p1 / 10) mod 10) when current_player = '1' else BCD_Encoder((seconds_p2 / 10) mod 10);
    HEX0 <= BCD_Encoder(seconds_p1 mod 10) when current_player = '1' else BCD_Encoder(seconds_p2 mod 10);

    -- LED Indicator for Running State
    LEDR(0) <= running;

end Behavioral;
