function startAWScluster(numInstances, price, instanceType)

cmdd = ['starcluster start -c mediumcluster -b ' num2str(price) ...
    ' -s ' num2str(numInstances) ' -i ' instanceType '  myWarp2Cluster'];
system(cmdd);

%{
    starcluster start --help
http://aws.amazon.com/ec2/instance-types/
http://aws.amazon.com/ec2/pricing/
%}
    