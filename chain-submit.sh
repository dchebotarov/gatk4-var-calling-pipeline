
# Submit several SLURM jobs in a way that each job is dependent on the proevious one. E.g.:
# chain-submit job1 job2 job3
# will submit job1, and then submit job2 with the flag --dependency=afterok with the job ID that job1 received; then same for job3.
# Usage: chain-submit <space separated list of SLURM files>

args=$@
echo $# arguments

#for var in $args ; do
#  echo $var

#done

echo Submitting $1
command="sbatch --parsable $1"
echo $command

N=`$command`

shift
while (( $# )) ; do

  echo Submitting $1 as dependent on $N
  command="sbatch --parsable --dependency=afterok:$N $1"
  echo $command
  N=`$command`
  shift

done
echo Last job id: $N

