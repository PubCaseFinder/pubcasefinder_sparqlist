# Get RIKEN BRC cell data

## Parameters

* `nando_id` NANDO ID
  * default: 2200865 
  * example: 2200865

## Endpoint

https://knowledge.brc.riken.jp/sparql

## `result` 
```sparql
# id, ラベル, descriptionに，型つきプレーンリテラルとプレーンリテラルが混在しているので，これらをプレーンリテラルに統一して出力
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX brso: <http://purl.jp/bio/10/brso/>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
SELECT 
DISTINCT ?id_plain as ?ID 
?hp as ?Homepage 
?cell_label_plain as ?Cell_name 
?description_e_plain as ?Description_e
?description_j_plain as ?Description_j 
FROM <http://metadb.riken.jp/db/xsearch_cell_brso>
WHERE {
 ?cell dct:identifier ?id;
    foaf:homepage ?hp;
    dc:description ?description_e;
    dc:description ?description_j;
    rdfs:label ?cell_label;
    brso:donor ?donor.
    FILTER(lang(?description_e) = "en")
    FILTER(lang(?description_j) = "ja")
	BIND (STR(?id) as ?id_plain)
	BIND (STR(?cell_label) as ?cell_label_plain)
	BIND (STR(?description_e) as ?description_e_plain)	
	BIND (STR(?description_j) as ?description_j_plain)	
 ?donor obo:RO_0000091 ?disease. # <http://purl.obolibrary.org/obo/RO_0000091>
 OPTIONAL {?disease rdfs:seeAlso ?ontology}
 FILTER (CONTAINS(STR(?ontology), "{{nando_id}}"))
}
 ORDER BY ?ID

```

## Output
```javascript
({result})=>{ 
  return result.results.bindings.map(data => {
    return Object.keys(data).reduce((obj, key) => {
      obj[key] = data[key].value;
      return obj;
    }, {});
  });
}
```

## Description
- NanbyoDataで理研の細胞情報を表示させるために利用しているSPARQListです。
- 理研のエンドポイントを利用しています。
- 編集：高月（2024/01/12)