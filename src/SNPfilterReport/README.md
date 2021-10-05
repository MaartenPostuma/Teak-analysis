# SNPFilterReport
Snakemake pipeline that filters a large .vcf file (as outputted by pipelines such as epiGBS and Stacks), in multiple ways and 
provides a report showing the effects of these filter steps on 3 different ordination methods: PCA, MDS, and ward clustering.

The pipeline uses 5 different parameters to filter: 
  * individual missingness: the amount of missingness allowed per individual
  * max missing: the percentage of individuals a SNP should be present in.
  * minor allele frequency: the frequency that the minor allele of a SNP should occur
  * hardy-weinberg p-value: Any SNPs more significantly out of hardy-weinberg equilibrium will be removed
  * minimal DP: the minimal amount of coverage required for a SNP.
  
Individual missingness is used in the first 2 steps to lower the amount of data.
The other 4 are then used. First seperately, with all non-tested parameters set to 0 and secondly using a set of parameters of which 
for one a range is used.

The pipeline consists of a config.yaml file allowing the specification of the parameters, a Snakefile, and a RmarkDown file to create
the report. To create the plots in the report a file specifying to which metapopulation  population belong. The following tab seperated format needs to be used.

```
pop   metaPop
pop1  metaPop1
pop2  metaPop1
pop3  metaPop2
```

File structure is extremely rigid at this point. Individuals should be named as ```popIdentifier_indIdentifier``` with no other underscores. 

Requirements: 
  * R3.5 or later,
  * Snakemake
  * vcftools
 

Can be installed using conda:
`conda env create -f configFiltering.yaml`
 
 The pipeline is run with the following command:
  `snakemake -s Snakefile-SNPFilterReport -j 12`
