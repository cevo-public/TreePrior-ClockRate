from subprocess import call
import argparse
from contextlib import contextmanager
import os, sys
from tempfile import mkstemp

# a safe way to cd
# taken from: http://stackoverflow.com/questions/431684/how-do-i-cd-in-python/24176022#24176022
@contextmanager
def cd(newdir):
    prevdir = os.getcwd()
    os.chdir(os.path.expanduser(newdir))
    try:
        yield
    finally:
        os.chdir(prevdir)

def get_beast_call(filename):
	return ["java", "-jar", "/cluster/home/dlouis/BEASTv2.4.7/lib/beast.jar", filename]

def get_submit_call(filename):
	submit_call = ['bsub']
	submit_call.append('-W 120:00')
	submit_call.append('-R rusage[mem=1500]')
	submit_call.append('-oo{0}'.format(filename.replace('xml', 'job')))
	submit_call.extend(get_beast_call(filename))
	return submit_call

def create_path_sampling_script(original_analysis_filename, output_filename, root_dir, nr_steps, chain_length):
	with open(original_analysis_filename, 'r') as f:
		analysis = f.read()

	hook_dict = {}
	hook_dict['NR_STEPS_HOOK'] = nr_steps
	hook_dict['ROOT_DIR_HOOK'] = root_dir
	hook_dict['CHAIN_LENGTH_HOOK'] = chain_length

	new_head = """<run spec='beast.inference.PathSampler' nrOfSteps="{NR_STEPS_HOOK}" rootdir="{ROOT_DIR_HOOK}" chainLength="{CHAIN_LENGTH_HOOK}" burnInPercentage="20" doNotRun="true">
	cd $(dir)
	java -cp $(java.class.path) beast.app.beastapp.BeastMain $(resume/overwrite) -java -seed $(seed) beast.xml
	<mcmc""".format(**hook_dict)

	new_tail = "</mcmc>\n</run>"

	analysis = analysis.replace('<run', new_head)
	analysis = analysis.replace('</run>', new_tail)

	with open(output_filename, 'w') as f:
		f.write(analysis)

def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('analysis_filename', help='path and name of the original xml analysis file')
	parser.add_argument('root_dir', help='path to root directory in which analyses should be created')
	parser.add_argument('chain_length', type=int, help='length of MCMC chain')
	parser.add_argument('nr_steps', type=int, help='nr of steps')
	parser.add_argument('--local', help='only sets up the analysis; for local testing',
						action='store_true')
	args = parser.parse_args()
	root_dir = args.root_dir+str(args.nr_steps)+'_steps/'
	tmp_file, tmp_filename = mkstemp(suffix='.xml')
	create_path_sampling_script(args.analysis_filename, tmp_filename, root_dir, args.nr_steps, args.chain_length)
	call(get_beast_call(tmp_filename))
	if not args.local:
		for s in xrange(args.nr_steps):
			with cd(root_dir+'step'+str(s)):
				# we have to create the results directory for the files to be written into
				os.mkdir('results')
				submit_call = get_submit_call('beast.xml')
				print(submit_call)
				call(submit_call)
	os.remove(tmp_filename)

if __name__ == '__main__': main()