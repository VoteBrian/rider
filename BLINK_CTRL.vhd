
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


entity BLINK_CTRL is
    generic ( DEFAULT_LVL : natural := 0 );
    port ( CLOCK   : in   std_logic;
           ENABLE  : in   std_logic;
           LEVEL   : in   std_logic_vector(7 downto 0);
           LED_OUT : out  std_logic);
end BLINK_CTRL;

architecture RTL of BLINK_CTRL is

    constant DATA_LENGTH : positive := 32;

    component COUNTER is
    generic ( DATA_LENGTH : positive );
    port ( CLOCK  : in   std_logic;
           RESET  : in   std_logic;
           ENABLE : in   std_logic;
           LOAD   : in   std_logic;
           UPDN   : in   std_logic;
           DATA   : in   std_logic_vector (DATA_LENGTH-1 downto 0);
           CARRY  : out  std_logic;
           Q      : out  std_logic_vector (DATA_LENGTH-1 downto 0) );
    end component;
           
    -- period signals
    signal T_LOAD   : std_logic;
    signal T_DATA   : std_logic_vector(DATA_LENGTH-1 downto 0);
    signal T_CARRY  : std_logic;
    
    -- brightness signals
    signal B_LOAD   : std_logic;
    signal B_DATA   : std_logic_vector(DATA_LENGTH-1 downto 0);
    signal B_CARRY  : std_logic;
    
    -- state signals
    type STATE_TYPE is ( LOADING, LED_ON, LED_OFF );
    signal STATE      : STATE_TYPE;
    signal NEXT_STATE : STATE_TYPE;

begin

    T_DATA <= "00000000000000001000000000000000";
    
    -- update brightness level
    process (LEVEL)
    begin
        case LEVEL is
            when "00000000" =>
                B_DATA <= "00000000000000000000000010000000";
            when "00000001" =>
                B_DATA <= "00000000000000000000000100000000";
            when "00000010" =>
                B_DATA <= "00000000000000000000001000000000";
            when "00000011" =>
                B_DATA <= "00000000000000000000010000000000";
            when "00000100" =>
                B_DATA <= "00000000000000000000100000000000";
            when "00000101" =>
                B_DATA <= "00000000000000000001000000000000";
            when "00000110" =>
                B_DATA <= "00000000000000000010000000000000";
            when others =>
                B_DATA <= "00000000000000000100000000000000";
        end case;
    end process;
    
    -- state machine
    process (STATE, ENABLE, T_CARRY, B_CARRY)
    begin
        NEXT_STATE <= STATE;
        
        if ENABLE = '1' then
            case STATE is
                when LOADING =>
                    LED_OUT <= '0';
                    
                    T_LOAD <= '1';
                    B_LOAD <= '1';
                    
                    NEXT_STATE <= LED_ON;
                when LED_ON =>
                    LED_OUT <= '1';
                    
                    T_LOAD <= '0';
                    B_LOAD <= '0';
                    
                    if B_CARRY = '1' then
                        NEXT_STATE <= LED_OFF;
                    end if;
                when LED_OFF =>
                    LED_OUT <= '0';
                    
                    T_LOAD <= '0';
                    B_LOAD <= '0';
                    
                    if T_CARRY = '1' then
                        NEXT_STATE <= LOADING;
                    end if;
            end case;
        else
            NEXT_STATE <= LOADING;
            
            LED_OUT <= '0';
            
            T_LOAD <= '1';
            B_LOAD <= '1';
        end if;
    end process;
    
    process (CLOCK)
    begin
        if rising_edge (CLOCK) then
            STATE <= NEXT_STATE;
        end if;
    end process;
    

    B_COUNTER : COUNTER
    generic map ( 32 )
    port map ( CLOCK  => CLOCK,
               RESET  => '0',
               ENABLE => ENABLE,
               LOAD   => B_LOAD,
               UPDN   => '1',
               DATA   => B_DATA,
               CARRY  => B_CARRY,
               Q      => open );

    T_COUNTER : COUNTER
    generic map ( 32 )
    port map ( CLOCK  => CLOCK,
               RESET  => '0',
               ENABLE => ENABLE,
               LOAD   => T_LOAD,
               UPDN   => '1',
               DATA   => T_DATA,
               CARRY  => T_CARRY,
               Q      => open );

end RTL;

