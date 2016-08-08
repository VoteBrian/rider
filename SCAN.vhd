library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SCAN is
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
end SCAN;

architecture RTL of SCAN is

    component DECAY is
    port ( CLOCK      : in   std_logic;
           BTN_START  : in   std_logic;
           LED_OUT    : out  std_logic );
    end component;
    
    component COUNTER is
    generic ( DATA_LENGTH : positive := 32 );
    port ( CLOCK  : in   std_logic;
           RESET  : in   std_logic;
           ENABLE : in   std_logic;
           LOAD   : in   std_logic;
           UPDN   : in   std_logic;
           DATA   : in   std_logic_vector (DATA_LENGTH-1 downto 0);
           CARRY  : out  std_logic;
           Q      : out  std_logic_vector (DATA_LENGTH-1 downto 0) );
           
    end component;
    
    signal LED_ARRAY : std_logic_vector (7 downto 0);
    signal START     : std_logic_vector (7 downto 0);
    signal LOAD      : std_logic;
    signal DATA      : std_logic_vector (31 downto 0);
    signal CARRY     : std_logic;
    
    signal POSITION      : unsigned (3 downto 0);
    signal NEXT_POSITION : unsigned (3 downto 0);
    
    type DIR_TYPE is (DIR_UP, DIR_DOWN);
    signal DIRECTION      : DIR_TYPE;
    signal NEXT_DIRECTION : DIR_TYPE;

begin
    -- DATA <= "00000000010111110101111000010000";
    DATA <= "00000101111101011110000100000000"; -- 1 second
    -- DATA <= "00000000000000000100000000000000"; -- simulation
    
    OUT0 <= LED_ARRAY(0);
    OUT1 <= LED_ARRAY(1);
    OUT2 <= LED_ARRAY(2);
    OUT3 <= LED_ARRAY(3);
    OUT4 <= LED_ARRAY(4);
    OUT5 <= LED_ARRAY(5);
    OUT6 <= LED_ARRAY(6);
    OUT7 <= LED_ARRAY(7);
    
    LOAD <= not (ENABLE and not CARRY);
    
    
    process (CARRY)
        variable pos : natural := 0;
        variable dir : boolean := false;
    begin
        if rising_edge (CARRY) then
            if dir = false then
                -- positive direction
                if pos = 7 then
                    pos := pos - 1;
                    dir := true;
                else
                    pos := pos + 1;
                end if;
            else
                -- negative direction
                if pos = 0 then
                    pos := pos + 1;
                    dir := false;
                else
                    pos := pos - 1;
                end if;
            end if;
            
            for I in 7 downto 0 loop
                if I = pos then
                    START(I) <= '1';
                else
                    START(I) <= '0';
                end if;
            end loop;
        end if;
    end process;
    

    G : for I in 7 downto 0 generate
    begin
        D : DECAY
        port map ( CLOCK     => CLOCK,
                   BTN_START => START(I),
                   LED_OUT   => LED_ARRAY(I) );
    end generate;
    
    C : COUNTER
    port map ( CLOCK  => CLOCK,
               RESET  => '0',
               ENABLE => ENABLE,
               LOAD   => LOAD,
               UPDN   => '1',
               DATA   => DATA,
               CARRY  => CARRY,
               Q      => open );

end RTL;

