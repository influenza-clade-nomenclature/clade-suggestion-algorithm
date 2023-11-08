print(config)

rule fetch_tree:
    output:
        "auspice/original_{lineage}.json"
    params:
        url= config["tree_url"]
    shell:
        """
        curl {params.url} -o {output}
        """

rule suggest_new_clades:
    input:
        tree = "auspice/original_{lineage}.json",
        weights = "../seasonal_{lineage}/config/weights.json",
        aliases = "../seasonal_{lineage}/config/aliases.json",
        params = "../seasonal_{lineage}/config/suggestion_params.json",
    output:
        "auspice/suggested_{lineage}.json"
    shell:
        """
        python3 scripts/add_new_clades.py --tree {input.tree} \
                        --config {input.params} \
                        --aliases {input.aliases} \
                        --weights {input.weights} \
                        --output {output}
        """


rule all:
    input:
        expand("auspice/suggested_{lineage}.json",
                lineage = ['A-H3N2_HA', 'A-H3N2_NA', 'B-Vic_HA'])
