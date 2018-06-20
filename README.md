# Happy update

The discussions were fruitful and Puppet changed they way service restarts are logged: https://tickets.puppetlabs.com/browse/PUP-8908

# A thought experiment

I was discussing something with a sysadmin and we determined there is an edge case where Puppet can, by failing to bounce a service (possibly through no fault of the service or Puppet), leave the system in an indeterminant state. 

To compound this further, depending on the nature of the failure to restart, the service could be running with the old PID, meaning that the bad, old config (or bad, old binary) is still running and Puppet doesn't act to fix it upon it in subsequent puppet runs.

This could leave the estate in a bad place, expecially if the failure to restart is intermittant, affecting a minority of production nodes. I wrote this code to bounce ideas off some fellow Puppet users to see if we can find a better way to deal with this.


# To run this experiment:
1. Classify a node that uses SystemV init scripts with this class (I used SLES11SP3 for no apparent reason)
2. Do a puppet run. The service should start; note the PID (cat /var/run/my_service.pid)
3. Set the class parameter '$fail\_to\_restart' to a value other than false using site.pp, Hiera, or the PE console
4. The next puppet run, the service will fail to stop, causing Puppet to report a failure to bounce the service
5. Subsequent puppet runs don't try to manage the service, but it is running under the old PID with the old config
6. This is bad, because Puppet didn't guarantee the end state, nor did it report on it in an actionable way.

The end result is that Admins would have to start and stop the service across their entire estate (bolt, tasks or mcollective, anyone?) to know that things are in their proper state.
