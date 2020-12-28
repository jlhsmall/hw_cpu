`timescale 1ns / 1ps
`include "config.v"

module stall(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire[2:0] if_stall,
    input wire[2:0] mem_stall
)