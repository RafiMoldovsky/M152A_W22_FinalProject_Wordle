module word_db (input [24:0] word, output wire in_db);

//Bloom filter storing 100 words in 256 bits with 2 hash functions
// ['wedge', 'fluff', 'giddy', 'lathe', 'group', 'began', 'steel', 'dowel', 'twine', 'union']
// ['crier', 'ingot', 'dutch', 'amend', 'elfin', 'cheat', 'write', 'bitty', 'skull', 'notch']
// ['fetid', 'coyly', 'boney', 'dingy', 'prank', 'peach', 'trend', 'chief', 'pesto', 'axial']
// ['older', 'found', 'posit', 'rival', 'spunk', 'locus', 'gavel', 'stone', 'hussy', 'flown']
// ['cleat', 'mushy', 'given', 'bayou', 'verso', 'being', 'butch', 'slink', 'smile', 'bride']
// ['march', 'leery', 'grass', 'spike', 'tower', 'khaki', 'chump', 'pecan', 'abbot', 'verve']
// ['lipid', 'aloud', 'booze', 'surer', 'quirk', 'dwell', 'movie', 'whiff', 'dense', 'afire']
// ['churn', 'eking', 'fussy', 'fever', 'stack', 'plaza', 'agent', 'irony', 'junto', 'shunt']
// ['bowel', 'right', 'altar', 'abbey', 'raven', 'gonad', 'three', 'trunk', 'debut', 'adept']
// ['proxy', 'fetus', 'gloss', 'stunk', 'brawl', 'novel', 'paint', 'tabby', 'splat', 'cruel']
localparam [7:0] hash_params [0:1] [0:4] = {
{8'h00e6, 8'h00c5, 8'h0085, 8'h00f9, 8'h00f4},
{8'h00b6, 8'h00fa, 8'h0077, 8'h00dc, 8'h0077}
};

localparam [255:0] bloom_filter = {
16'b100111111001011,
16'b000101110111001,
16'b111000000111000,
16'b011000001101100,
16'b100100111101111,
16'b110000111100101,
16'b010101110110101,
16'b010110100101001,
16'b111111011011100,
16'b110101111000110,
16'b111010000000010,
16'b011011010101011,
16'b111100110111100,
16'b111000111000111,
16'b111011001101111,
16'b001110110000110
};

wire [7:0] hash_table [0:1][0:4];

wire [7:0] hash [0:1];

wire [0:1] in_db_i;

genvar i,j;
generate
for (i = 0 ; i < 2 ; i = i + 1) begin : which_hash
for (j = 0; j < 5; j = j + 1) begin : which_letter
assign hash_table[i][j] = hash_params[i][j] * word[5*j + 4:5*j];
end
assign hash[i] = hash_table[i][0] + hash_table[i][1] + hash_table[i][2] + hash_table[i][3] + hash_table[i][4];
assign in_db_i[i] = bloom_filter[hash[i]];
end
endgenerate

assign in_db = &in_db_i;

endmodule
