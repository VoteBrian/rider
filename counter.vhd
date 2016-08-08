library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter is
    generic ( DATA_LENGTH : positive := 32 );
    port ( CLOCK  : in   std_logic;
           RESET  : in   std_logic;
           ENABLE : in   std_logic;
           LOAD   : in   std_logic;
           UPDN   : in   std_logic;
           DATA   : in   std_logic_vector (DATA_LENGTH-1 downto 0);
           CARRY  : out  std_logic;
           Q      : out  std_logic_vector (DATA_LENGTH-1 downto 0) );
           
end counter;

architecture RTL of COUNTER is
    signal COUNT : unsigned (DATA_LENGTH-1 downto 0) := (others => '0');
    
    constant ZEROS : unsigned (DATA_LENGTH-1 downto 0) := (others => '0');
    constant ONES  : unsigned (DATA_LENGTH-1 downto 0) := (others => '1');
	 
begin
    
    -- count output
    Q <= std_logic_vector(COUNT);
    CARRY <= '1' when UPDN = '0' and COUNT = ONES else
             '1' when UPDN = '1' and COUNT = ZEROS else
             '0';
	 
    process (CLOCK, RESET)
    begin
        if RESET = '1' then
            -- set count to zeros
            COUNT <= ZEROS;
        elsif rising_edge (CLOCK) then
            if ENABLE = '1' then
                if LOAD = '1' then
                    COUNT <= unsigned(DATA);
                elsif UPDN = '0' then
                    -- count up
                    if COUNT = ONES then
                        -- overflow
                        COUNT <= ZEROS;
                    else
                        COUNT <= COUNT + 1;
                    end if;
                elsif UPDN = '1' then
                    -- count down
                    if COUNT = ZEROS then
                        COUNT <= ONES;
                    else
                        COUNT <= COUNT - 1;
                    end if;
                else
                    -- do nothing?
                end if;
            end if;
        end if;
    end process;
end RTL;

