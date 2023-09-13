version 1.0


workflow UpdateVariantIdsFabio {
    input {
        File vcf
        String basename
        Int disk_space =  3*ceil(size(vcf, "GB"))
    }
    
    call UpdateVariantIdsImpl {
		input:
			vcf = vcf,
			basename = basename,
			disk_space = disk_space
	}
	
	output {
		File output_vcf = UpdateVariantIdsImpl.output_vcf
	}
}


task UpdateVariantIdsImpl {
    input {
        File vcf
        String basename
        Int disk_space =  3*ceil(size(vcf, "GB"))
    }

    command <<<
        zcat ~{vcf} | awk -v OFS='\t' '{ if ( !($1 ~ /^"#"/) && $5 < $4)  $3=$1":"$2":"$5":"$4; else $3=$1":"$2":"$4":"$5; print $0 }' | bgzip -c > ~{basename}.vcf.gz
    >>>

    output {
        File output_vcf = "~{basename}.vcf.gz"
    }
    runtime {
        docker: "skwalker/imputation:with_vcftools"
        disks: "local-disk " + disk_space + " HDD"
        memory: "16 GB"
    }
}