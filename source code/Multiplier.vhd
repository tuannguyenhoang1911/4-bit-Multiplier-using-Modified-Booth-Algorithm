library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Multiplier is
port
(

	------------ CLOCK ------------
	CLOCK2_50       	:in    	std_logic;
	CLOCK3_50       	:in    	std_logic;
	CLOCK4_50       	:in    	std_logic;
	CLOCK_50        	:in    	std_logic;

	------------ KEY ------------
	KEY             	:in    	std_logic_vector(3 downto 0);

	------------ SW ------------
	SW              	:in    	std_logic_vector(9 downto 0);

	------------ LED ------------
	LEDR            	:out   	std_logic_vector(9 downto 0);

	------------ Seg7 ------------
	HEX0            	:out   	std_logic_vector(6 downto 0);
	HEX1            	:out   	std_logic_vector(6 downto 0);
	HEX2            	:out   	std_logic_vector(6 downto 0);
	HEX3            	:out   	std_logic_vector(6 downto 0);
	HEX4            	:out   	std_logic_vector(6 downto 0);
	HEX5            	:out   	std_logic_vector(6 downto 0)
);

end entity;

---------------------------------------------------------
--  Structural coding
---------------------------------------------------------


architecture rtl of Multiplier is

-- declare --
signal x,y,d,d1       :  std_logic_vector(3 downto 0);
signal c              :  std_logic_vector(4 downto 0);
signal t              :  std_logic;
signal s1,s2          :  std_logic_vector(6 downto 0);
signal s,sum          :  std_logic_vector(7 downto 0);
------------------------------------------------------------
component CLAfulladder
port(
a,b    :in std_logic_vector(5 downto 0);
Cin    :in std_logic;
Cout   :out std_logic;
s      :out std_logic_vector(5 downto 0)
); 
end component;
-------------------------------------------------------------
begin
process(SW(3 downto 0))
begin
if SW(3 downto 0)="1000" then
y<= SW(3 downto 0);
x<= SW(7 downto 4);
else
x <= SW(3 downto 0);
y <= SW(7 downto 4);
end if;
end process;
------------------------------------
PROCESS(c,x,y,d,d1)
begin
c<=y&'0';
case (c(2 downto 0)) is
  when"000" => s1<="0000000";
  when"001" => if x(3)='1' then s1<="111"&x;else s1<="000"&x; end if;
  when"010" => if x(3)='1' then s1<="111"&x;else s1<="000"&x; end if;
  when"011" => if x(3)='1' then s1<="11"&x&'0'; else s1<="00"&x&'0';end if;
  when"100" => d1<=(not x)+'1';if d1(3)='1' then s1<="11"&d1&'0'; else s1<="00"&d1&'0';end if;
  when"101" => d1<=(not x)+'1';if d1(3)='1' then s1<="111"&d1;else s1<="000"&d1; end if;
  when"110" => d1<=(not x)+'1';if d1(3)='1' then s1<="111"&d1;else s1<="000"&d1; end if;
  when others => s1<="0000000";
end case; 
case (c(4 downto 2)) is
  when"000" => s2<="0000000";
  when"001" => if x(3)='1' then s2<='1'&x&"00";else s2<='0'&x&"00"; end if;
  when"010" => if x(3)='1' then s2<='1'&x&"00";else s2<='0'&x&"00"; end if;
  when"011" => if x(3)='1' then s2<=x&"000";else s2<=x&"000"; end if;
  when"100" => d<=(not x)+'1';if d(3)='1' then s2<=d&"000";else s2<=d&"000"; end if;
  when"101" => d<=(not x)+'1';if d(3)='1' then s2<='1'&d&"00";else s2<='0'&d&"00"; end if;
  when"110" => d<=(not x)+'1';if d(3)='1' then s2<='1'&d&"00";else s2<='0'&d&"00"; end if;
  when others => s2<="0000000";
end case; 
end process;
--------------------------------------------
T0: CLAfulladder port map(s1(5 downto 0),s2(5 downto 0),'0',t,s(5 downto 0));
s(6)<=s1(6) xor s2(6) xor t; 
-------------------------------------------------
process(x,y,sum,s)
begin
if s(6)='1' then s(7)<='1'; else s(7)<='0';end if;
if (x="1000") and (y="1000") then
	  sum<="01000000";
else
     sum<=s;
end if;
end process;
-------------------------------------------------
LEDR(7 downto 0) <= sum;
end rtl;
--------------------------------------------------
--------------------------------------------------
------------Carry Look Ahead Adder----------------
library ieee;
use ieee.std_logic_1164.all;
entity CLAfulladder is
port(
a,b    :in std_logic_vector(5 downto 0);
Cin    :in std_logic;
Cout   :out std_logic;
s      :out std_logic_vector(5 downto 0)
);
end entity;
architecture behave of CLAfulladder is
signal P,G: std_logic_vector (5 downto 0);
signal C: std_logic_vector (4 downto 0);
begin
P<=a xor b;
G<=a and b;
Process (P,G,C)
begin
C(0)<=G(0) or (P(0) and Cin);
s(0)<=P(0) xor Cin;
f0:for i in 1 to 4 loop
C(i)<=G(i) or (P(i) and C(i-1));
s(i)<=P(i) xor C(i-1);
end loop;
Cout<=G(5) or (P(5) and C(4));
s(5)<=P(5) xor C(4);
end process;
end behave;
