rule survivor_filter:  # used by both modes
    input:
        os.path.join("{path}", "{tumor}--{normal}", "{outdir}", "{prefix}" + get_filext("vcf"))
        if config["mode"].startswith("p") is True else
        os.path.join("{path}", "{sample}", "{outdir}", "{prefix}" + get_filext("vcf"))
    output:
        os.path.join("{path}", "{tumor}--{normal}", "{outdir}", "survivor", "{prefix}" + get_filext("vcf"))
        if config["mode"].startswith("p") is True else
        os.path.join("{path}", "{sample}", "{outdir}", "survivor", "{prefix}" + get_filext("vcf"))
    params:
        excl = exclude_regions(),
        cmd = survivor_cmd("filter")
    conda:
        "../environment.yaml"
    threads:
        get_nthreads("survivor")
    resources:
        mem_mb = get_memory("survivor"),
        tmp_mb = get_tmpspace("survivor")
    shell:
        """
        set -x

        # run dummy or real job
        if [ "{config[echo_run]}" -eq "1" ]; then
            cat "{input}" > "{output}"
        else
            if [ "{params.excl}" -eq "1" ]; then
                {params.cmd}
            else
                ln -sr "{input}" "{output}"
            fi
        fi
        """

rule survivor_merge:  # used by both modes
    input:
        [os.path.join("{path}", "{tumor}--{normal}", get_outdir(c), "survivor", c + get_filext("vcf"))
         for c in get_callers()]
        if config["mode"].startswith("p") is True else
        [os.path.join("{path}", "{sample}", get_outdir(c), "survivor", c + get_filext("vcf"))
         for c in get_callers()]
    params:
        cmd = survivor_cmd("merge")
    output:
        os.path.join("{path}", "{tumor}--{normal}", survivor_cmd("merge")[-1])
        if config["mode"].startswith("p") is True else
        os.path.join("{path}", "{sample}", survivor_cmd("merge")[-1])
    conda:
        "../environment.yaml"
    threads:
        get_nthreads("survivor")
    resources:
        mem_mb = get_memory("survivor"),
        tmp_mb = get_tmpspace("survivor")
    shell:
        """
        set -x

        # run dummy or real job
        if [ "{config[echo_run]}" -eq "1" ]; then
            cat "{input}" > "{output}"
        else
            echo "{input}" | tr ' ' '\n' > "{params.cmd[2]}" &&
            {params.cmd}
        fi
        """
