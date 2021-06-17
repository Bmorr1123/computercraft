for i = 1, 16 do
    if turtle.getItemCount(i) > 0 then
		if i == 9 then
			read()
		end
        print(string.format("%2i: %2ix ", i, turtle.getItemCount(i))..turtle.getItemDetail(i).name)
    end
end
