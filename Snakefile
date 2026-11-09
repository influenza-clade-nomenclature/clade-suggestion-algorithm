configfile: "config.yaml"
print(config)

rule all:
    input:
        expand("auspice/suggested_{lineage}.json", lineage=config["lineages"]),

rule fetch_tree:
    output:
        "auspice/original_{lineage}.json"
    params:
        url=lambda wildcards: config["tree_by_lineage"][wildcards.lineage],
    shell:
        """
        curl \
            --compressed \
            --header 'Accept: application/vnd.nextstrain.dataset.main+json' \
            {params.url:q} > {output}
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
