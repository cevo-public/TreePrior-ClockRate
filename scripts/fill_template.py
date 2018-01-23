import argparse

"""
	This script fills a template for sequence simulation such as
	simulation_template.xml in this directory.
	It assumes that there is a tree.nwk file and a taxa.txt
	to specify the tree and the taxa for the simulation.
	Sequence length and rate can be specified as command line
	arguments.
"""

def fill_template(output_dir, seq_length, rate, num_runs = 1, tree_file='tree.nwk', taxa_file='taxa.txt'):
	tree_f = open(tree_file)
	tree = tree_f.read()
	tree_f.close()

	taxa_f = open(taxa_file)
	taxa = taxa_f.read()
	taxa_f.close()

	hook_dict = {}
	hook_dict['SEQ_LENGTH_HOOK'] = seq_length
	hook_dict['RATE_HOOK'] = rate
	hook_dict['TAXA_HOOK'] = taxa
	hook_dict['TREE_HOOK'] = tree
	hook_dict['NUM_RUNS_HOOK'] = num_runs
	hook_dict['OUTPUT_HOOK'] = output_dir + "ebola_" + str(seq_length) + "_" + str(rate)

	template_f = open('simulation_template.xml', 'r')
	template = template_f.read()
	template_f.close()

	output = template.format(**hook_dict)

	out_f = open('ebola_simulation.xml', 'w')
	out_f.write(output)
	out_f.close()

def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('seq_length')
	parser.add_argument('rate')
	args = parser.parse_args()

	fill_template("./", args.seq_length, args.rate)

	
if __name__ == '__main__': main()