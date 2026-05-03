                    is_valid_retire := false;
                    if (not is_x(pc_wb)) and (pc_wb /= pc_wb_prev) and (wb_instr /= PIPE_NOP) and (wb_instr /= x"00000000") then
                        is_valid_retire := true;
                    end if;
