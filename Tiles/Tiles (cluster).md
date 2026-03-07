Successor to  [[Tales (cluster)]]. 
[[Tiles-Repo]] holds the code
[[Tiles (proxmox)]] provisions most of the nodes
* [[nuc-g3p-1]]
* [[nuc-g3p-2]]
* [[nuc-g2p-1]]
* [[nuc-g2p-2]]
Also
* [[Lancer]] some of the time (Halo Strix)
* [[Rising]] (Ryzen 9)


To change / improve:
* Host on Proxmox on a farm of SFF servers (N95 and N150 machines)
* 3 control-plane nodes for actual rolling upgrades
* No nodes (? maybe just a worker) on Raconteur, leave it to be a NAS
* Figure out how to upgrade Talos and k8s on a regular basis
* Push the diffs back to the PR (steal Google terraform-example code for this)
* Terraform to manage external stuff
	* External DNS
	* Buckets for loki, mimir
	* Talos deployment itself (onto Proxmox)
* Monitoring
	* make it multi-tenant, tenant = cluster
	* "normal" mimir and loki, don't fight with the all-in-one deployment
	* Move backing store from Minio to "real buckets" on GCS
	* Drop Tempo for now
	* Maybe: internal certs for secure uploading
	* External access to push metrics (to a specific tenant) so cluster-on-a-SBC instances don't need their own metrics and logs stacks
* Try using Raconteur CSI for everything except for ephemeral, so jobs don't get stuck on a local drive. (It will be a little slower but probably not in a way that is noticeable)
* Maybe: staging environment to test deployments before going to the "real" cluster. Right now the entire stack would fit on a single machine (of the 5 available).
	* Ideally (I think) we'd bring up the current stack, apply the change, check functionality, and take it down again.
* "Operational" tests run ~daily for things we can't have alerts for