/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter
 *
 * An error can be injected into the design by invoking compilation with
 * the option:  +define+FORCE_LOAD_ERROR
 *
 **********************************************************************/

 // comentariu block se face cu /* */

module instr_register (tb_ifc.dut interf);
 
timeunit 1ns/1ns;
import instr_register_pkg::*;
  instruction_t  iw_reg [0:31];  // an array of instruction_word structures
  rezultat_t     rez;

  // write to the register
  always@(posedge interf.clk, negedge interf.reset_n)   // write into register
    if (!interf.reset_n) begin
      foreach (iw_reg[i])
        iw_reg[i] = '{opc:ZERO,default:0};  // reset to all zeros
    end
    else if (interf.load_en) begin
      case(interf.opcode)
      PASSA: rez =interf.operand_a;
      PASSB: rez =interf.operand_b;
      ADD:   rez =interf.operand_a+interf.operand_b;
      SUB:   rez =interf.operand_a-interf.operand_b;
      MULT:  rez =interf.operand_a*interf.operand_b;
      DIV:   rez =interf.operand_a/interf.operand_b;
      MOD:   rez =interf.operand_a%interf.operand_b;
      endcase

      iw_reg[interf.write_pointer] = '{interf.opcode,interf.operand_a,interf.operand_b, rez};
    end

  // read from the register
  always@(posedge interf.clk, negedge interf.reset_n) begin
   interf.instruction_word <= iw_reg[interf.read_pointer];  // continuously read from register
  end
// compile with +define+FORCE_LOAD_ERROR to inject a functional bug for verification to catch
`ifdef FORCE_LOAD_ERROR
initial begin
  force interf.operand_b = interf.operand_a; // cause wrong value to be loaded into operand_b
end
`endif

endmodule : instr_register
