-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Tomáš Hrbáč (xhrbact00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity UART_RX_FSM is
    port(
       CLK          : in std_logic;
       RST          : in std_logic;
       COUNT        : in std_logic_vector(4 downto 0);
       COUNT2       : in std_logic_vector(3 downto 0);
       DIN          : in std_logic;
       RX_ENABLE    : out std_logic;
       CNT_ENABLE   : out std_logic;
       DOUT_VLD     : out std_logic
    );
end entity;


architecture behavioral of UART_RX_FSM is
    type state_t is (IDLE, STARTBIT, DATA, STOPBIT, VALID);
    signal state : state_t := IDLE;
begin
    state_logic: process (CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                state <= IDLE;
            else
                case state is
                when IDLE => if DIN = '0' then
                                state <= STARTBIT;
                             end if;
                when STARTBIT => if COUNT = "11000" then
                                    state <= DATA;
                                 end if;
                when DATA => if COUNT2 = "10000" then
                                state <= STOPBIT;
                             end if;
                when STOPBIT => if COUNT = "10000" then
                                    state <= VALID;
                                end if;
                when VALID => 
                    state <= IDLE;
                when others => null;
                end case;
            end if;
        end if;
    end process state_logic;

    output_logic : process(state)
    begin
        case (state) is
            when IDLE =>
                DOUT_VLD <= '0';
                RX_ENABLE <= '0';
                CNT_ENABLE <= '0';
            when STARTBIT =>
                DOUT_VLD <= '0';
                 RX_ENABLE <= '0';
                 CNT_ENABLE <= '1';
            when DATA =>
                 DOUT_VLD <= '0';
                 RX_ENABLE <= '1';
                 CNT_ENABLE <= '1';
            when STOPBIT =>
                 DOUT_VLD <= '0';
                 RX_ENABLE <= '0';
                 CNT_ENABLE <= '1';
            when VALID =>
                 DOUT_VLD <= '1';
                 RX_ENABLE <= '0';
                 CNT_ENABLE <= '0';
          end case;
     end process output_logic;
end architecture;
