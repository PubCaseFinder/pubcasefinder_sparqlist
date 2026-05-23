# [PCF] FILTER: GET GENE by MONDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0008199
  * example: 0018096, 0003847, 0018096, 0007477

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({mondo_id}) => {
  mondo_id = mondo_id.replace(/MONDO:/g,"")
  return mondo_id;
}
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterm: <http://purl.org/dc/terms/>
PREFIX nando: <http://nanbyodata.jp/ontology/nando#>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT DISTINCT
?hgnc_gene_symbol
?gene_id
?disease_info
?disease_info_ja
?source_name
?inheritance_en
?inheritance_ja
WHERE {
  VALUES ?mondo_input {
    #{{#each mondo_id_list}} mondo:MONDO_{{this}} {{/each}}
    mondo:MONDO_{{mondo_id_list}}
  }

  {
    SELECT DISTINCT ?mondo_input ?disease WHERE {
      VALUES ?mondo_input {
        #{{#each mondo_id_list}} mondo:MONDO_{{this}} {{/each}}
        mondo:MONDO_{{mondo_id_list}}
      }
      ?mondo_sub_tier rdfs:subClassOf* ?mondo_input ;
                      skos:exactMatch ?exactMatch_disease .
      FILTER(CONTAINS(STR(?exactMatch_disease), "mim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
      BIND(IRI(REPLACE(STR(?exactMatch_disease), "http://identifiers.org/mim/|http://identifiers.org/omim/", "https://omim.org/entry/")) AS ?disease)
    }
  }

  ?as sio:SIO_000628 ?disease ;
      sio:SIO_000628 ?gene ;
      dcterm:source ?source .

  ?disease rdf:type ncit:C7057 ;
           dcterm:identifier ?disease_id ;
           rdfs:seeAlso [rdfs:label ?disease_name] .

  ?gene rdf:type ncit:C16612 ;
        sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] ;
        dcterm:identifier ?gene_id .

  OPTIONAL {
    ?disease nando:hasInheritance ?inheritance .
    ?inheritance rdfs:label ?inheritance_ja .
    FILTER (lang(?inheritance_ja) = "ja") .
    GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp> {
      ?inheritance rdfs:label ?inheritance_en .
    }
  }

  BIND(CONCAT(?disease_name, IF(CONTAINS(STR(?disease), "Orphanet"), ", ORPHA:", ", OMIM:"), ?disease_id) AS ?disease_info)
  FILTER (lang(?disease_name) = "")

  OPTIONAL {
    ?disease dcterm:identifier ?disease_id ;
             rdfs:seeAlso [rdfs:label ?disease_name_ja]
    BIND(CONCAT(?disease_name_ja, IF(CONTAINS(STR(?disease), "Orphanet"), ", ORPHA:", ", OMIM:"), ?disease_id) AS ?disease_info_ja)
    FILTER (lang(?disease_name_ja) = "ja")
  }

  BIND(IF(STR(?source) = "http://www.orphadata.org/data/xml/en_product6.xml", "Orphadata",
       IF(STR(?source) = "ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/mim2gene_medgen", "OMIM", "GenCC")) AS ?source_name)
}
ORDER BY ?hgnc_gene_symbol

```

## Output
```javascript
({result}) => {
  const rows = result.results.bindings.map((data) => {
    return Object.keys(data).reduce((obj, key) => {
      obj[key] = data[key].value;
      return obj;
    }, {});
  });

  const grouped = new Map();
  const splitValues = (value, separator) => {
    if (!value) return [];
    return value.split(separator).map((item) => item.trim()).filter(Boolean);
  };
  const addValues = (set, values) => {
    values.forEach((value) => set.add(value));
  };

  rows.forEach((row) => {
    const key = `${row.gene_id}\t${row.hgnc_gene_symbol}`;
    if (!grouped.has(key)) {
      grouped.set(key, {
        hgnc_gene_symbol: row.hgnc_gene_symbol || "",
        gene_id: row.gene_id || "",
        disease_info: new Set(),
        disease_info_ja: new Set(),
        source_name: new Set(),
        inheritance_en: new Set(),
        inheritance_ja: new Set()
      });
    }

    const item = grouped.get(key);
    addValues(item.disease_info, splitValues(row.disease_info, " | "));
    addValues(item.disease_info_ja, splitValues(row.disease_info_ja, " | "));
    addValues(item.source_name, splitValues(row.source_name, " | "));
    addValues(item.inheritance_en, splitValues(row.inheritance_en, ","));
    addValues(item.inheritance_ja, splitValues(row.inheritance_ja, ","));
  });

  return Array.from(grouped.values()).map((item) => ({
    hgnc_gene_symbol: item.hgnc_gene_symbol,
    gene_id: item.gene_id,
    disease_info: Array.from(item.disease_info).join(" | "),
    disease_info_ja: Array.from(item.disease_info_ja).join(" | "),
    source_name: Array.from(item.source_name).join(" | "),
    inheritance_en: Array.from(item.inheritance_en).join(", "),
    inheritance_ja: Array.from(item.inheritance_ja).join(", ")
  })).sort((a, b) => {
    return a.hgnc_gene_symbol.localeCompare(b.hgnc_gene_symbol) || a.gene_id.localeCompare(b.gene_id);
  });
}
```