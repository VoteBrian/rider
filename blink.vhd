library IEEE;
use IEEE.std_logic_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity BLINK is
end BLINK;

architecture BEHAVIOR of BLINK is

    component BLINK_CTRL is
    generic ( DEFAULT_LVL : natural := 0 );
    port ( CLOCK   : in   std_logic;
           LEVEL   : in   std_logic_vector(7 downto 0);
           ENABLE  : in   std_logic;
           LED_OUT : out  std_logic );
    end component;
    
    signal CLOCK   : std_logic;
    signal ENABLE  : std_logic;
    signal LED_OUT : std_logic;
    signal LEVEL   : std_logic_vector(7 downto 0);
    
    signal STOP_CLOCK : boolean := false;

begin
    
    LED_0 : BLINK_CTRL
    port map ( CLOCK   => CLOCK,
               LEVEL   => LEVEL,
               ENABLE  => ENABLE,
               LED_OUT => LED_OUT );
               
    process
    begin
        while not STOP_CLOCK loop
            CLOCK <= '0';
            wait for 5 ns;
            CLOCK <= '1';
            wait for 5 ns;
        end loop;
    end process;
    
    process
    begin
        LEVEL <= "00000000";
        ENABLE <= '0';
        wait for 10 ns;
        
        ENABLE <= '1';
        wait for 500 ns;
        
        LEVEL <= "00000001";
        wait for 1 ms;
        
        LEVEL <= "00000100";
        wait for 1 ms;
        
        STOP_CLOCK <= true;
        wait;
    end process;

end BEHAVIOR;

