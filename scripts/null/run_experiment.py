from fill_template import fill_template
from subprocess import call
import os, re, argparse
import xml_to_fasta

"""
	This script takes a template filename and an output directory.
	Other parameters are set in the main function.
	The template filename specifies a beast analysis file which will
	be filled with simulated data and subsequently analyzed with BEAST.
"""

seed = 127

def fill_analysis_template(output_dir, template_filename, seq_length, rate, treenum, chain_length):
	hook_dict = {}
	hook_dict['OUTPUT_LOG_HOOK'] = output_dir + "ebola_" + str(seq_length) + "_" + str(rate) + "_" + str(treenum)
	hook_dict['OUTPUT_TREE_HOOK'] = output_dir + "ebola_" + str(seq_length) + "_" + str(rate) + "_" + str(treenum)
	hook_dict['CLOCK_MEAN_HOOK'] = rate
	hook_dict['CLOCK_STDEV_HOOK'] = rate/5
	hook_dict['CHAIN_LENGTH_HOOK'] = chain_length
	hook_dict['LOG_FREQUENCY_HOOK'] = chain_length/10000

	dates_f = open('dates.txt')
	dates = dates_f.read()
	dates_f.close()
	hook_dict['DATES_HOOK'] = dates

	template_f = open(template_filename, 'r')
	template = template_f.read()
	template_f.close()

	output = template.format(**hook_dict)

	out_f = open('ebola_tmp.xml', 'w')
	out_f.write(output)
	out_f.close()

def make_prior_analysis(analysis_filename, output_filename, old_chain_length, new_chain_length):
	input_f = open(analysis_filename, 'r')
	original = input_f.read()
	input_f.close()

	analysis_name = os.path.splitext(analysis_filename)[0]
	output_name = os.path.splitext(output_filename)[0]
	replaced = original.replace('<run id="mcmc" spec="MCMC" chainLength="' + str(old_chain_length), '<run id="mcmc" spec="MCMC" sampleFromPrior="true" chainLength="' + str(new_chain_length))
	replaced = replaced.replace('logEvery="' + str(old_chain_length/10000), 'logEvery="' + str(new_chain_length/10000))
	replaced = replaced.replace(analysis_name, output_name)

	out_f = open(output_filename, 'w')
	out_f.write(replaced)
	out_f.close()

def remove_tree_logger(analysis_filename):
	input_f = open(analysis_filename, 'r')
	original = input_f.read()
	input_f.close()

	regex = re.compile('<logger id="treelog.t:ebola".*</logger>', re.DOTALL)

	out_f = open(analysis_filename, 'w')
	out_f.write(regex.sub("", original))
	out_f.close()

def get_beast_call(filename):
	return ["java", "-jar", "/cluster/home/dlouis/BEASTv2.4.7/lib/beast.jar", "-seed", str(random.randint(1,255)), "-overwrite", filename]

def get_submit_call(filename):
	submit_call = ['bsub']
	submit_call.append('-W 120:00')
	submit_call.append('-R rusage[mem=1500]')
	submit_call.append('-oo{0}'.format(filename.replace('xml', 'job')))
	submit_call.extend(get_beast_call(filename))
	return submit_call

def main():	
	parser = argparse.ArgumentParser()
	parser.add_argument('template_filename', help='path and name of analysis template xml file')
	parser.add_argument('output_dir', help='path of output directory')
	args = parser.parse_args()
	output_dir = args.output_dir
	if not os.path.exists(output_dir):
		os.makedirs(output_dir)

	# set parameters
	seq_lengths = [100, 500, 1000, 15000]
	rates = [0.1]
	trees = [0,1,2,3,4,5,6,7,8,9]
	num_runs = 10
	chain_length = {}
	chain_length[0]     = 600000000
	chain_length[100]   = 100000000
	chain_length[500]   = 100000000
	chain_length[1000]  = 100000000
	chain_length[15000] =  60000000

	# generate analysis files
	for seq_length in seq_lengths:
		for rate in rates:
			for tree in trees:
				# fill the template for SEQUENCE SIMULATION
				fill_template(output_dir, seq_length, rate, tree, num_runs)
				# adjust template for ANALYSIS
				fill_analysis_template(output_dir, args.template_filename, seq_length, rate, tree, chain_length[seq_length])
				call(get_beast_call("ebola_simulation.xml"))
				#call(["beast", "ebola_simulation.xml"])
	os.remove('ebola_tmp.xml')
	os.remove('ebola_simulation.xml')
	os.remove('sequences.xml')


	# generate prior analysis files
	for rate in rates:
		for i in xrange(num_runs):
			analysis_filename = output_dir + 'ebola_' + str(seq_lengths[0]) + '_' + str(rate) + "_" + str(i) + ".xml"
			#make_prior_analysis(analysis_filename, output_dir + 'ebola_0_' + str(rate) + "_" + str(i) + ".xml", chain_length[100], chain_length[0])

	# submit jobs
	calls = open(output_dir + 'ebola_null.sh', 'w')
	for filename in os.listdir(output_dir):
		if filename.endswith('.xml'):
			filename = output_dir+filename
			submit_call = get_submit_call(filename)
			print submit_call
			call(submit_call)
			calls.write(' '.join(submit_call)+"\n")
	calls.close()

if __name__ == '__main__': main()
