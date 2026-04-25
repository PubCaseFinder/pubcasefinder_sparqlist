# [PCF] FILTER: GET GENE IDs by MONDO ID - https://dev-pubcasefinder.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0008199
  * example: 1200021, 1200220, 1200477

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql/

## `mondo_id_list`
```javascript
({mondo_id}) => {
  mondo_id = mondo_id.replace(/MONDO:/gi,"").replace(/[\s,]/g," ")
   if (mondo_id.match(/[^\s]/)) return mondo_id.split(/\s+/);
  return false;
  //return mondo_id;
}
```

## `result` 
```sparql
PREFIX : <http://nanbyodata.jp/ontology/nando#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX oboinowl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX mondo: <http://purl.obolibrary.org/obo/MONDO_>
SELECT DISTINCT
(CONCAT("MONDO:", "{{mondo_id_list}}" )) AS ?panel_disease_id
?panel_disease_name
?reference_mondo_id
?mondo_en AS ?disease_name_en
?mondo_ja AS ?disease_name_ja
#?mondo_sub_tier AS ?mondo_url
?ncbi_gene_id
?hgnc_gene_symbol AS ?gene_symbol
?rating AS ?classification
?source
?source_url
?moi_en
?moi_ja

WHERE {
  # mondo_input 라벨
  VALUES ?mondo_input { mondo:{{mondo_id_list}} }

  OPTIONAL {
    ?mondo_input rdfs:label ?panel_disease_name .
    FILTER(lang(?panel_disease_name) = "")
  }
  {
    SELECT DISTINCT ?mondo_sub_tier WHERE {
      VALUES ?mondo_input { mondo:{{mondo_id_list}} }
      ?mondo_sub_tier rdfs:subClassOf* ?mondo_input .
      FILTER(CONTAINS(STR(?mondo_sub_tier), "MONDO"))
    }
  }
  ?mondo_sub_tier oboinowl:id ?reference_mondo_id .
  ?mondo_sub_tier skos:exactMatch ?exactMatch_disease .
  FILTER(CONTAINS(STR(?exactMatch_disease), "/omim.org/entry/") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
  #BIND(IRI(replace(STR(?exactMatch_disease), 'https://omim.org/entry/', 'http://identifiers.org/mim/')) AS ?disease) .
  BIND(IRI(REPLACE(STR(?exactMatch_disease), "http://identifiers.org/mim/|http://identifiers.org/omim/", "https://omim.org/entry/")) AS ?disease) .

  OPTIONAL {
    ?mondo_sub_tier rdfs:label ?mondo_en .
    FILTER (lang(?mondo_en) = "") . 
  }
  OPTIONAL {
    ?mondo_sub_tier rdfs:label ?mondo_ja .
    FILTER (lang(?mondo_ja) = "ja") .
  }
  
#association
  #?as sio:SIO_000628 ?exactMatch_disease ;
  ?as sio:SIO_000628 ?disease ;
      sio:SIO_000628 ?gene ;
      dcterms:source ?source_uri .
  FILTER (?source_uri != <https://search.thegencc.org/download/action/submissions-export-csv>)
  
  #mode of inheritance
  OPTIONAL {
    ?disease :hasInheritance ?inheritance .
    ?inheritance rdfs:label ?moi_en, ?moi_ja .
    FILTER (lang(?moi_en) = "" && lang(?moi_ja) = "ja") .
  }
  #?exactMatch_disease rdf:type ncit:C7057 . omim이 완벽하지 못하여 생기는 문제
  #gene info
  ?gene rdf:type ncit:C16612 ;
        dcterms:identifier ?ncbi_gene_id ;
        sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] .
  
  OPTIONAL {
    #GenCC source
    ?source_uri obo:IAO_0000114 ?gencc_rating ;
    #            :hasInheritance ?moi ;
                dcterms:creator ?submitter .
    #mode of inheritance
    #?moi rdfs:label ?moi_en ;
    #     rdfs:label ?moi_ja .
    #FILTER (lang(?moi_en) = "") .
    #FILTER (lang(?moi_ja) = "ja") .
  }
  BIND(IF(CONTAINS(STR(?source_uri), "orphadata"), ?exactMatch_disease,
          IF(CONTAINS(STR(?source_uri), "mim2gene_medgen"), ?exactMatch_disease, ?source_uri)) AS ?source_url)

  BIND(IF(CONTAINS(STR(?source_uri), "orphadata"), "Orphadata",
          IF(CONTAINS(STR(?source_uri), "mim2gene_medgen"), "OMIM", CONCAT(?submitter, " (GenCC)"))) AS ?source)

  BIND(IF(CONTAINS(STR(?source_uri), "orphadata") || CONTAINS(STR(?source_uri), "mim2gene_medgen"),
          "Supportive", ?gencc_rating) AS ?rating)
}
order by ?hgnc_gene_symbol
```

## Output
```javascript
({text({result}){ // tsv
    var vars = result.head.vars;
    var list = result.results.bindings;
    var text = vars.join("\t") + "\n";
    for(var i = 0; i < list.length; i++){
      var values = [];
      for(var j = 0; j < vars.length; j++){
        var val = ""; 
        if(list[i][vars[j]]) val = list[i][vars[j]].value;
        if(val.match(/^\".+\"$/)) val = val.match(/^\"(.+)\"$/)[1];
        values.push(val);
      }
      text += values.join("\t") + "\n";
    }
    return text;
  }
})
/*
({ result }) => {
  const grouped = {};

  result.results.bindings.forEach(data => {
    const entry = Object.keys(data).reduce((obj, key) => {
      obj[key] = data[key].value;
      return obj;
    }, {});

    const mondoId = entry.reference_mondo_id;

    if (!grouped[mondoId]) {
      grouped[mondoId] = [];
    }
    grouped[mondoId].push(entry);
  });

  return grouped;
}
*/
```
