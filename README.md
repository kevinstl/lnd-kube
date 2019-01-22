# Lightning Kube LND

Lightning Kube LND provides a simple way to deploy Lightning Node Daemon (LND) into Kubernetes.           

[<img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.png" width="100px">](https://kubernetes.io/docs/home "Kubernetes")  [<img src="https://raw.githubusercontent.com/lightningnetwork/lnd/master/logo.png" width="100px">](https://github.com/lightningnetwork/lnd "LND")  [<img src="https://jenkins.io/images/logos/jenkins-x/jenkins-x-256.png" width="100px">](https://jenkins-x.io "Jenkins X")

This project implements a Lightning Node running in Kubernetes using Lightning Network Daemon (LND) deployed by Jenkins X. 

The [Lightning Kube](https://github.com/kevinstl/lightning-kube) project gives a better high level view of how to install a fully functional Lightning Node. 


To install this project:
```
Requirments:

- Running Kubernetes cluster
- Jenkins X Executable installation
- Jenkins X instance running on Kubernetes cluster
```
*See [Lightning Kube](https://github.com/kevinstl/lightning-kube) for help with requirements.

3. Clone this project. `git clone https://github.com/kevinstl/lightning-kube-lnd ~/Developer/projects/lightning-kube-lnd`
4. Change to project directory `cd ~/Developer/projects/lightning-kube-lnd`
5. Import this project into your Jenkins X instance. `jx import`

If the installation is successful you should see the lnd pod running from [kubernetes dashboard](http://minikube-easy:30000/#!/pod?namespace=lightning-kube).