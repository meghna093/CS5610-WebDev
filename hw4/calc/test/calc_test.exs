defmodule CalcTest do
  use ExUnit.Case
  doctest Calc

test "TestCase1" do
	assert Calc.number("1")==true
end

test "TestCase2" do
	assert Calc.split("24/6+(5-4)")==["24","/","6","+","(","5","-","4",")"]
end 

test "TestCase3" do
	assert Calc.divd("+(") == ["+","("]
end

test "TestCase4" do
	assert Calc.handle_op([5,5],["/"],"-") == {[1], ["-"]}
end

test "TestCase5" do
	assert Calc.eval("2 + 3")==5
end

test "TestCase6" do
	assert Calc.eval("5 * 1")==5
end

test "TestCase7" do
	assert Calc.eval("20 / 4")==5
end

test "TestCase8" do
	assert Calc.eval("15 - 10")==5
end

test "TestCase9" do
	assert Calc.eval("24 / 6 + (5 - 4)")==5
end

test "TestCase10" do
	assert Calc.eval("1 + 3 * 3 + 1")==11
end

test "TestCase11" do
	assert Calc.eval1(["24", "/", "6", "+", "(", "5", "-", "4", ")"],[],[])==5
end

test "TestCase12" do
	assert Calc.eval1(["(","5","/","5",")","*","(","5","+","4",")"],[],[])==9
end

test "TestCase13" do
	assert Calc.eval1(["(","5","/","5",")","*","(","5","+","4",")"],[],[])==9
end

test "TestCase14" do
	assert Calc.handle_brck([1,2],["-","(","+"])=={[3],["-"]}
end
end

