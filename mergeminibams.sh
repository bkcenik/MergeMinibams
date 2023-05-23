#!/bin/sh
# minibam file merging scripts
# author: Bercin Cenik

directory=/path/to/directory
subdirectory=/bam/fastq_pass/alignment/*
file1='filename'
file2='filename'
file3='filename'
file4='filename'

##currently having an issue putting the first line in the shell script, added it manually

for item in "file1" "file2" "file3" "file4"
do
    #scriptfile=${!item}.scripts.sh
    echo "#!/bin/sh" > ${!item}.scripts.sh
    echo "# Bercin Cenik" >> ${!item}.scripts.sh
    ## add lines for slurm scheduler here and write them into the scripts.sh file ##
    echo " " >> ${!item}.scripts.sh
    echo "module load samtools" >> ${!item}.scripts.sh
    echo " " >> ${!item}.scripts.sh
    ls -d ${directory}/${!item}/${subdirectory} > ${!item}.minibamlist.txt
    sort -V ${!item}.minibamlist.txt > ${!item}.minibamlist.ordered.txt
    cat ${!item}.minibamlist.ordered.txt | xargs -n 10 > ${!item}.minibamlist.ordered.grouped.txt
    line_count=$(wc -l < ${!item}.minibamlist.ordered.grouped.txt)
    echo "Number of lines in ${!item}.minibamlist.ordered.grouped.txt: ${line_count}"
    seq -f "samtools merge -@ 8 ./merge.R1/merged_R1_%04g.bam" 1 ${line_count} > "${!item}.headers.txt"
    paste -d ' ' ${!item}.headers.txt ${!item}.minibamlist.ordered.grouped.txt >> ${!item}.scripts.sh
    ##clean up files
    rm ${!item}.minibamlist.txt
    rm ${!item}.minibamlist.ordered.txt
    rm ${!item}.minibamlist.ordered.grouped.txt
    rm ${!item}.headers.txt
    ##make directories and subdirectories
    mkdir merge.${!item}
    mkdir merge.${!item}/merge.R1
    mkdir merge.${!item}/merge.R2
    mkdir merge.${!item}/merge.R3
    mv ${!item}.scripts.sh merge.${!item}
    echo "done with ${!item}"
    sbatch merge.${!item}/${!item}.scripts.sh
done

## note: need to move into subdirectory and run script there, otherwise throws error


###testing these###


for item in "file1" "file2" "file3" "file4"
do
    ls -d ${directory}/${!item}/${subdirectory} > ${!item}.minibamlist.txt
    sort -V ${!item}.minibamlist.txt > ${!item}.minibamlist.ordered.txt
    cat ${!item}.minibamlist.ordered.txt | xargs -n 10 > ${!item}.minibamlist.ordered.grouped.txt
    line_count=$(wc -l < ${!item}.minibamlist.ordered.grouped.txt)
    echo "Number of lines in ${!item}.minibamlist.ordered.grouped.txt: ${line_count}"
    line_count=$((line_count/10))    
    seq -f "samtools merge -@ 8 ./merge.R2/merged_R2_%03g.bam" 1 ${line_count} > "${!item}.mergeR2.headers.txt"
    rm ${!item}.minibamlist.txt
    rm ${!item}.minibamlist.ordered.txt
    rm ${!item}.minibamlist.ordered.grouped.txt
done

for item in "file1" "file2" "file3" "file4"
do
cat ${directory}/${!item}.scripts.sh | tail -n +14 | cut -f 5 -d " " > ${directory}/${!item}.R1list.txt
sort -V ${directory}/${!item}.R1list.txt > ${directory}/${!item}.R1list.ordered.txt
cat ${directory}/${!item}.R1list.ordered.txt | xargs -n 10 > ${directory}/${!item}.R1list.ordered.grouped.txt
done


##example to make R3 scripts
for item in "file3"
do
    ls -d ${directory}/${!item}/${subdirectory} > ${!item}.minibamlist.txt
    sort -V ${!item}.minibamlist.txt > ${!item}.minibamlist.ordered.txt
    cat ${!item}.minibamlist.ordered.txt | xargs -n 10 > ${!item}.minibamlist.ordered.grouped.txt
    line_count=$(wc -l < ${!item}.minibamlist.ordered.grouped.txt)
    echo "Number of lines in ${!item}.minibamlist.ordered.grouped.txt: ${line_count}"
    line_count=$((line_count/100))    
    seq -f "samtools merge -@ 8 ./merge.R3/merged_R3_%02g.bam" 1 ${line_count} > "${!item}.mergeR3.headers.txt"
    rm ${!item}.minibamlist.txt
    rm ${!item}.minibamlist.ordered.txt
    rm ${!item}.minibamlist.ordered.grouped.txt
    mv ${!item}.mergeR3.headers.txt ${directory}/merge.${!item}
done

## another example for merging R3s
cat $item.mergeR2.scripts.sh | tail -n +14 | cut -f 5 -d " " > R1.list.txt
sort -V R1.list.txt > R1.list.ordered.txt
cat R1.list.ordered.txt | xargs -n 10 > R1.list.ordered.grouped.txt
paste -d ' ' $item.mergeR3.headers.txt R1.list.ordered.grouped.txt > $item.mergeR3.scripts.sh
