// Copyright 2020 Silicon Labs, Inc.
//
// This file, and derivatives thereof are licensed under the
// Solderpad License, Version 2.0 (the "License").
//
// Use of this file means you agree to the terms and conditions
// of the license and are in full compliance with the License.
//
// You may obtain a copy of the License at:
//
//     https://solderpad.org/licenses/SHL-2.0/
//
// Unless required by applicable law or agreed to in writing, software
// and hardware implementations thereof distributed under the License
// is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
// OF ANY KIND, EITHER EXPRESSED OR IMPLIED.
//
// See the License for the specific language governing permissions and
// limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Engineer:       Moritz Imfeld - moimfeld@student.ethz.ch                   //
//                                                                            //
// Design Name:    fpu_ss_tracer.sv (FPU_SS trace)                            //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Logs the following:                                        //
//                                                                            //
//                 - Time, Instruction, Result                                //
//                                                                            //
// Note:           Tracer is not capable of logging out-of-order completion   //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`ifdef FPU_SS_TRACER

module fpu_ss_tracer (
    input logic        clk_i,
    input logic        rst_ni,
    input logic        x_mem_valid_i,
    input logic        fpu_in_valid_i,
    input logic [ 4:0] rs1_i,
    input logic [ 4:0] rs2_i,
    input logic [ 4:0] rs3_i,
    input logic [31:0] instr_i,
    input logic        fpu_out_valid_i,
    input logic        fpu_out_ready_i,
    input logic [ 4:0] fpu_waddr_i,
    input logic [31:0] fpu_result_i,
    input logic        x_mem_result_valid_i,
    input logic        fpr_we_i,
    input logic [31:0] x_mem_result_i

);

  int    fpu_ss_trace_file;
  string fn;
  string fpu_ss_operation;
  string rd_s;
  string result;
  string rs1_s, rs2_s, rs3_s;
  string rs1_mem_s, rs2_mem_s, rs3_mem_s;
  string instruction;

  // open/close output file for writing
  initial begin
    wait(rst_ni == 1'b1);
    $sformat(fn, "fpu_ss_trace.log");
    fpu_ss_trace_file = $fopen(fn, "w");
    $fwrite(fpu_ss_trace_file, "time instruction result\n");

    while (1) begin

      @(negedge clk_i);
      if (fpu_in_valid_i) begin
        $sformat(rs1_s, "");
        $sformat(rs2_s, "");
        $sformat(rs3_s, "");
        unique casez(instr_i)
          fpu_ss_instr_pkg::FADD_S: begin
            $sformat(fpu_ss_operation, "fadd.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
            $sformat(rs2_s, ", f%0d", rs2_i);
          end
          fpu_ss_instr_pkg::FSUB_S: begin
            $sformat(fpu_ss_operation, "fsub.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
            $sformat(rs2_s, ", f%0d", rs2_i);
          end
          fpu_ss_instr_pkg::FMUL_S: begin
            $sformat(fpu_ss_operation, "fmul.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
            $sformat(rs2_s, ", f%0d", rs2_i);
          end
          fpu_ss_instr_pkg::FDIV_S: begin
            $sformat(fpu_ss_operation, "fdiv.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
            $sformat(rs2_s, ", f%0d", rs2_i);
          end
          fpu_ss_instr_pkg::FSGNJ_S: begin
            $sformat(fpu_ss_operation, "fsgnj.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
          end
          fpu_ss_instr_pkg::FSGNJN_S: begin
            $sformat(fpu_ss_operation, "fsgnjn.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
          end
          fpu_ss_instr_pkg::FSGNJX_S: begin
            $sformat(fpu_ss_operation, "fsgnjx.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
          end
          fpu_ss_instr_pkg::FMIN_S:begin
            $sformat(fpu_ss_operation, "fmin.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
            $sformat(rs2_s, ", f%0d", rs2_i);
          end
          fpu_ss_instr_pkg::FMAX_S: begin
            $sformat(fpu_ss_operation, "fmax.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
            $sformat(rs2_s, ", f%0d", rs2_i);
          end
          fpu_ss_instr_pkg::FSQRT_S: begin
            $sformat(fpu_ss_operation, "fsqrt.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
          end
          fpu_ss_instr_pkg::FMADD_S: begin
            $sformat(fpu_ss_operation, "fmadd.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
            $sformat(rs2_s, ", f%0d", rs2_i);
            $sformat(rs3_s, ", f%0d", rs3_i);
          end
          fpu_ss_instr_pkg::FMSUB_S: begin
            $sformat(fpu_ss_operation, "fmsub.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
            $sformat(rs2_s, ", f%0d", rs2_i);
            $sformat(rs3_s, ", f%0d", rs3_i);
          end
          fpu_ss_instr_pkg::FNMSUB_S: begin
            $sformat(fpu_ss_operation, "fnmsub.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
            $sformat(rs2_s, ", f%0d", rs2_i);
            $sformat(rs3_s, ", f%0d", rs3_i);
          end
          fpu_ss_instr_pkg::FNMADD_S: begin
            $sformat(fpu_ss_operation, "fnmadd.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
            $sformat(rs2_s, ", f%0d", rs2_i);
            $sformat(rs3_s, ", f%0d", rs3_i);
          end
          fpu_ss_instr_pkg::FLE_S: begin
            $sformat(fpu_ss_operation, "fle.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
            $sformat(rs2_s, ", f%0d", rs2_i);
          end
          fpu_ss_instr_pkg::FLT_S: begin
            $sformat(fpu_ss_operation, "flt.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
            $sformat(rs2_s, ", f%0d", rs2_i);
          end
          fpu_ss_instr_pkg::FEQ_S: begin
            $sformat(fpu_ss_operation, "feq.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
            $sformat(rs2_s, ", f%0d", rs2_i);
          end
          fpu_ss_instr_pkg::FCLASS_S: begin
            $sformat(fpu_ss_operation, "fclass.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
          end
          fpu_ss_instr_pkg::FCVT_S_W: begin
            $sformat(fpu_ss_operation, "fcvt.w.s");
            $sformat(rs1_s, ", x%0d", rs1_i);
          end
          fpu_ss_instr_pkg::FCVT_W_S: begin
            $sformat(fpu_ss_operation, "fcvt.w.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
          end
          fpu_ss_instr_pkg::FCVT_WU_S: begin
            $sformat(fpu_ss_operation, "fcvt.wu.s");
            $sformat(rs1_s, ", f%0d", rs1_i);
          end
          fpu_ss_instr_pkg::FMV_X_W: begin
            $sformat(fpu_ss_operation, "fmv.x.w");
            $sformat(rs1_s, ", x%0d", rs1_i);
          end
          default: begin
            $sformat(fpu_ss_operation, "operation unknown");
            $display("fpu_ss_operation was set to operation unknown");
          end
        endcase // instr_i
      end
      if (x_mem_valid_i) begin
        $sformat(rs1_mem_s, "");
        $sformat(rs2_mem_s, "");
        $sformat(rs3_mem_s, "");
        unique casez(instr_i)
          fpu_ss_instr_pkg::FLW: begin
            $sformat(rs1_mem_s, ", x%0d", rs1_i);
          end
          fpu_ss_instr_pkg::FSW: begin
            $sformat(rs1_mem_s, ", x%0d", rs1_i);
            $sformat(rs2_mem_s, ", f%0d", rs1_i);
          end
        endcase
      end

      if (fpu_out_valid_i & fpu_out_ready_i) begin
        if (fpr_we_i) begin
          $sformat(rd_s, "f%0d", fpu_waddr_i);
          $sformat(result, "%.4f", $bitstoshortreal(fpu_result_i));
        end else begin
          $sformat(rd_s, "x%0d", fpu_waddr_i);
          $sformat(result, "%h", fpu_result_i);
        end
        $sformat(instruction, "%s %s%s%s%s", fpu_ss_operation, rd_s, rs1_s, rs2_s, rs3_s);
        $sformat(instruction, "%-30s", instruction);
        $fwrite(fpu_ss_trace_file, "%t\t\t %s \t\t%s", $time, instruction, result);
        $fwrite(fpu_ss_trace_file, "\n");
      end else if (x_mem_result_valid_i) begin
        if (fpr_we_i) begin
          $sformat(rd_s, "f%0d", fpu_waddr_i);
          $sformat(result, "%.4f", $bitstoshortreal(x_mem_result_i));
          $sformat(instruction, "flw %s%s%s%s", rd_s, rs1_mem_s, rs2_mem_s, rs3_mem_s);
          $sformat(instruction, "%-30s", instruction);
          $fwrite(fpu_ss_trace_file,"%t\t\t %s \t\t%s", $time, instruction, result);
          $fwrite(fpu_ss_trace_file, "\n");
        end else begin
          $sformat(result, "-----");
          $sformat(instruction, "fsw %s%s%s", rs1_mem_s, rs2_mem_s, rs3_mem_s);
          $sformat(instruction, "%-30s", instruction);
          $fwrite(fpu_ss_trace_file,"%t\t\t %s \t\t%s", $time, instruction, result);
          $fwrite(fpu_ss_trace_file, "\n");
        end
      end
    end

  end

  final begin
    $fclose(fpu_ss_trace_file);
  end

endmodule  // fpu_ss_tracer

`endif  // FPU_SS_TRACER
