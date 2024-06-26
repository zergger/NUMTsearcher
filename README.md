NUMTsearcher
=================

### Introduction

NUMTsearcher is an advanced bioinformatics tool designed to detect nuclear mitochondrial DNA segments (Numts) in genomes.

### Installation Dependency

NUMTsearcher requires the following third-party software. Please ensure they are installed and functioning correctly:
- **[seqkit](https://github.com/shenwei356/seqkit)**
- **[samtools](https://github.com/samtools/samtools)**
- **[LastZ](https://github.com/lastz/lastz)**
- **[PLastZ](https://github.com/AntoineHo/PLastZ)**
- **[mafToPsl](https://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/mafToPsl)**

### Usage Example

Assume `chr.fa` is your nuclear genome and `chrM.fa` is your mitochondrial genome.

1. **Reverse the mitochondrial genome using seqkit:**

    ```bash
    seqkit seq -rv chrM.fa -t dna > chrM_rev.fa
    ```

2. **Create a new mitochondrial genome starting at a new position using the `reorder_mt_genome.sh` script:**

    ```bash
    ./reorder_mt_genome.sh -i chrM.fa -o reorder_chrM.fa
    ```

3. **Search for the optimal K value using `searchK.sh`. Set your output folder with `-o` and specify the number of threads with `-t`:**

    ```bash
    ./searchK.sh -m chrM_rev.fa -n chr.fa -o output_fold -t thread_num
    ```

4. **After finding the optimal K value, use `NUMTsearcher.sh` to obtain Numt search results. The results will be in `output_fold/plastz.out`:**

    ```bash
    ./NUMTsearcher.sh -m chrM.fa -n chr.fa -o output_fold -t thread_num -k k_value
    ```

5. **Convert the results file to PSL format using `mafToPsl` and ensure it is in the `numt.tsv` file:**

    ```bash
    sed -i '1s/^/##maf version=1 scoring=lastz.v1.04.15\n/' output_fold/plastz.out
    mafToPsl chrM chr output_fold/plastz.out numt.tsv
    ```

6. **Extract Numt sequences:**

    ```bash
    ./extract_sequences.sh -i output_fold/plastz.out -o numt.fa -n chr
    ```

7. **Extract mitochondrial sequences:**

    ```bash
    ./extract_sequences.sh -i output_fold/plastz.out -o mt.fa -n chrM
    ```

By following these steps, you can effectively utilize NUMTsearcher to detect and analyze Numts in your genomic data.