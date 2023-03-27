/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test (tb_ifc.test interf);
 timeunit 1ns/1ns;
 import instr_register_pkg::*;
 

 parameter NUMBER_OF_TRANSACTION = 11;
  int seed = 555;
  int seed_r = 555;
  int seed_w = 555;

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    //------initializare read & write pointer -------------
    interf.write_pointer <= 5'h00;         // initialize write pointer
    interf.read_pointer  <= 5'h1F;         // initialize read pointer
    interf.load_en       <= 1'b0;          // initialize load control line
    interf.reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge interf.test_clk) ;     // hold in reset for 2 clock cycles
    interf.reset_n        <= 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge interf.test_clk) interf.load_en <= 1'b1;  // enable writing to register
    repeat (NUMBER_OF_TRANSACTION) begin
      @(posedge interf.test_clk) randomize_transaction;
      @(negedge interf.test_clk) print_transaction;
    end
    @(posedge interf.test_clk) interf.load_en <= 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i<NUMBER_OF_TRANSACTION; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back

      //-----incrementare read_pointer-----
      //@(posedge interf.test_clk) interf.read_pointer = i; //incredemtare liniara
      @(posedge interf.test_clk) interf.read_pointer <= $unsigned($random())%32; //atribuire valori random

      @(negedge interf.test_clk) print_results;
    end

    @(posedge interf.test_clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    interf.operand_a     <= $random(seed)%16;                 // between -15 and 15
    interf.operand_b     <= $unsigned($random)%16;            // between 0 and 15
    interf.opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    
   // -------incrementare write pointer liniara ------
   // interf.write_pointer <= temp++; //incredemtare liniara
    interf.write_pointer <= $unsigned($random())%32; //atribuire valori random
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", interf.write_pointer);
    $display("  opcode = %0d (%s)", interf.opcode, interf.opcode.name);
    $display("  operand_a = %0d",   interf.operand_a);
    $display("  operand_b = %0d\n", interf.operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", interf.read_pointer);
    $display("  opcode = %0d (%s)", interf.instruction_word.opc, interf.instruction_word.opc.name);
    $display("  operand_a = %0d",   interf.instruction_word.op_a);
    $display("  operand_b = %0d\n", interf.instruction_word.op_b);
  endfunction: print_results

endmodule: instr_register_test
