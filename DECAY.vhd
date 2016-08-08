library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity DECAY is
    port ( CLOCK      : in   std_logic;
           BTN_START  : in   std_logic;
           -- STEP_WIDTH : in   std_logic_vector(31 downto 0);
           LED_OUT    : out  std_logic );
end DECAY;

architecture RTL of DECAY is

    component BLINK_CTRL is
    generic ( DEFAULT_LVL : natural := 0 );
    port ( CLOCK   : in   std_logic;
           ENABLE  : in   std_logic;
           LEVEL   : in   std_logic_vector(7 downto 0);
           LED_OUT : out  std_logic);
    end component; 

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
    
    signal STEP_WIDTH : std_logic_vector(31 downto 0);
    
    signal ENABLE     : std_logic;
    signal LOAD       : std_logic;
    signal STEP_CARRY : std_logic;
    
    type STATE_TYPE is (IDLE, LOADING, DECAYING);
    signal STATE      : STATE_TYPE := IDLE;
    signal NEXT_STATE : STATE_TYPE := IDLE;
    
    signal LEVEL      : unsigned(7 downto 0) := "00000000";
    signal NEXT_LEVEL : unsigned(7 downto 0) := "00000000";

begin
    STEP_WIDTH <= "00000000101111101011110000100000";
    -- STEP_WIDTH <= "00000000000000000010000000000000"; -- simulation
    
    -- state machine
    process (BTN_START, STATE, STEP_CARRY)
    begin   
        case STATE is
            when IDLE =>
                LOAD <= '1';
                ENABLE <= '0';
                NEXT_LEVEL <= "00000111";
                NEXT_STATE <= STATE;
                
                if rising_edge (BTN_START) then
                    NEXT_STATE <= LOADING;
                end if;
            when LOADING =>
                LOAD <= '1';
                ENABLE <= '1';
                NEXT_LEVEL <= LEVEL;
                NEXT_STATE <= DECAYING;
            when DECAYING =>
                LOAD <= '0';
                ENABLE <= '1';
                NEXT_LEVEL <= LEVEL;
                NEXT_STATE <= STATE;
                
                if STEP_CARRY = '1' then
                    if LEVEL = 0 then
                        NEXT_STATE <= IDLE;
                        NEXT_LEVEL <= "00000000";
                    else
                        NEXT_LEVEL <= LEVEL - 1;
                        NEXT_STATE <= LOADING;
                    end if;
                end if;
            when others =>
                LOAD <= '1';
                ENABLE <= '0';
                NEXT_LEVEL <= "00000111";
                NEXT_STATE <= IDLE;
        end case;
    end process;
    
    process (CLOCK)
    begin
        if rising_edge(CLOCK) then
            STATE <= NEXT_STATE;
            LEVEL <= NEXT_LEVEL;
        end if;
    end process;

    CONTROLLER : BLINK_CTRL
    generic map ( 0 )
    port map ( CLOCK   => CLOCK,
               ENABLE  => ENABLE,
               LEVEL   => std_logic_vector(LEVEL),
               LED_OUT => LED_OUT );

    STEP_TIMER : COUNTER
    generic map ( 32 )
    port map ( CLOCK  => CLOCK,
               RESET  => '0',
               ENABLE => ENABLE,
               LOAD   => LOAD,
               UPDN   => '1',
               DATA   => STEP_WIDTH,
               CARRY  => STEP_CARRY,
               Q      => open );

end RTL;

