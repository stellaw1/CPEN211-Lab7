module ALU_tb();
  reg [15:0] sim_ain, sim_bin;
  wire [15:0] sim_out;
  reg [1:0] sim_ALUop;
  wire [2:0] sim_status; //status[0]=Z, status[1]=N, status[2]=V
  reg err;

  ALU DUT(sim_ain, sim_bin, sim_ALUop, sim_out, sim_status);

  task error_check;
    input [15:0] expected, actual;
    begin
      //if the data_out in the instantiated DUT is erraneous, display the actual and expected state, and set err = 1
      if (actual !== expected) begin
			  $display("Error: expected: %d, actual: %d", expected, actual);
			  err = 1'b1;
			end
    end
  endtask

  initial begin
    sim_ain = 16'b00000101_01100010; //1378
    sim_bin = 16'b01011000_00100010;//22562
    err = 1'b0;

    //test ADD
    sim_ALUop = 2'b00;
    #5;
    if (sim_out != 16'b0101110110000100) begin
      $display("output: %b expected: %b, Test1",sim_out, 16'b0101110110000100);
      err = 1'b1;
    end


    //test SUB
    sim_ALUop = 2'b01;
    #5;
    if (sim_out != 16'b1010110101000000) begin
      $display("output: %b expected: %b ,Test2",sim_out, 16'b1010110101000000);
      err = 1'b1;
    end

    //test AND
    sim_ALUop = 2'b10;
    #5;
    if (sim_out != 16'b0000000000100010) begin
      $display("output: %b expected: %b ,Test3",sim_out, 16'b0000000000100010);
      err = 1'b1;
    end


    //test NOT B
    sim_ALUop = 2'b11;
    #5;
    if (sim_out != 16'b1010011111011101) begin
      $display("output: %b expected: %b, Test4",sim_out, 16'b1010011111011101);
      err = 1'b1;
    end

    //test Zero flag
    sim_ain = 16'b0; //1378
    sim_bin = 16'b0;//22562
    #5;

    sim_ALUop = 2'b00;
    #5;

    $display ("Z");
    error_check(1, sim_status[0]); //check Z flag

    //test Negative flag with 1 - 32 = -31
    sim_ain = 16'b0_0000000_00000001; //1
    sim_bin = 16'b0_0000000_00100000;//32
    #5;

    sim_ALUop = 2'b01;
    #5;

    $display ("N");
    error_check(1, sim_status[1]); // check N flag

    // //test Overflow flag with 32767 - (-32513) = 16'b11111111_00000000
    // sim_ain = 16'b0_1111111_11111111; //1
    // sim_bin = 16'b1_1111111_00000001;//32
    // #5;

    // sim_ALUop = 2'b01;
    // #5;

    // $display ("V");
    // error_check(1, sim_status[2]); //check V flag

    //test V with 2 - 7. expect V = 0
    sim_ain = 16'b0_0000000_00000010; //2
    sim_bin = 16'b0_0000000_00000111;//7
    #5;

    sim_ALUop = 2'b01;
    #5;

    $display ("V 2");
    error_check(0, sim_status[2]); //check V flag

    //test V with 0x8000 - 2. expect V = 1
    sim_ain = 16'b1_0000000_00000000; //0x8000
    sim_bin = 16'b0_0000000_00000010;//2
    #5;

    sim_ALUop = 2'b01;
    #5;

    $display ("V 3");
    error_check(1, sim_status[2]); //check V flag


    //print results, whether errors were found
    if (~err) 
        $display ("All test cases passed with no errors. ");
    else
        $display ("Error found. ");
    
  end
endmodule