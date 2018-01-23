from subprocess import call
import os

def get_line(filename, n):
	with open(filename, 'r') as f:
		for i in xrange(n):
			l = f.readline()
	return l.rstrip()

def get_ess_from_line(l):
	return str(int(round(float(l.split(' ')[-1]))))

def main():
	data = ['guinea', 'gire']
	models = ['bd', 'bdsky', 'const_coal', 'exp_coal', 'sky_coal', 'struct_coal']

	#data = ['gire']
	#models = ['struct_coal_modified', 'struct_coal_modified_onlySL']

	min_steps = 13
	max_steps = 16
	base_dir = '../results/'

	num_steps = max_steps - min_steps + 1
	for d in data:
		out_filename = base_dir + d + '/path_sampling/ess_summary.txt'
		with open(out_filename, 'w') as out_f:
			out_f.write('steps\t')
			for m in models:
				for i in xrange(num_steps):
					out_f.write(m+'\t')
			for s in range(max_steps):
				out_f.write('\n'+str(s)+'\t')
				for m in models:
					for curr_s in range(min_steps, max_steps+1):
						if s < curr_s:
							filename = base_dir + d + '/path_sampling/' + m + '/' + str(curr_s) + '_steps/analysis_raw.txt'
							out_f.write(get_ess_from_line(get_line(filename, curr_s + 3 + s)) + '\t')
						else:
							out_f.write('-\t')

if __name__ == '__main__' : main()