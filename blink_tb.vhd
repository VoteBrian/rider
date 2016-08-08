library IEEE;
use IEEE.std_logic_1164.all;
 
entity BLINK_TB is
end BLINK_TB;
 
architecture BEHAVIOR of BLINK_TB is 

    constant DATA_LENGTH : positive := 4;
 
    component SCAN is
    port ( CLOCK  : in  std_logic;
           ENABLE : in  std_logic;
           OUT0   : out std_logic;
           OUT1   : out std_logic;
           OUT2   : out std_logic;
           OUT3   : out std_logic;
           OUT4   : out std_logic;
           OUT5   : out std_logic;
           OUT6   : out std_logic;
           OUT7   : out std_logic );
    end component;
    

    --Inputs
    signal CLOCK  : std_logic := '0';
    signal ENABLE : std_logic := '0';
    
    signal LED0 : std_logic;
    signal LED1 : std_logic;
    signal LED2 : std_logic;
    signal LED3 : std_logic;
    signal LED4 : std_logic;
    signal LED5 : std_logic;
    signal LED6 : std_logic;
    signal LED7 : std_logic;

    -- Clock period definitions
    constant CLK_PERIOD : time := 10 ns;
    signal   STOP_CLOCK : boolean := FALSE;
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
    SCANNER: SCAN
    port map ( CLOCK  => CLOCK,
               ENABLE => ENABLE,
               OUT0   => LED0,
               OUT1   => LED1,
               OUT2   => LED2,
               OUT3   => LED3,
               OUT4   => LED4,
               OUT5   => LED5,
               OUT6   => LED6,
               OUT7   => LED7 );

    -- Clock process definitions
    CLK_PROCESS :process
    begin
        if not STOP_CLOCK then
            CLOCK <= '0';
            wait for CLK_PERIOD/2;
            CLOCK <= '1';
            wait for CLK_PERIOD/2;
        end if;
    end process;


    -- Stimulus process
    stim_proc: process
    begin		 
        -- init counter
        ENABLE <= '0';
        wait for 10 ns;
        
        ENABLE <= '1';
        wait for 20 ms;
        
        STOP_CLOCK <= TRUE;
        wait;
    end process;

END;
