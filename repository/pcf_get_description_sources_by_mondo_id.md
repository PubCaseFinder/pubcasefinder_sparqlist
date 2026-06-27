# [PCF] Get description sources by MONDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql

## Parameters

* `mondo_id` MONDO ID
  * default: MONDO:0016244
  * example: MONDO:0008434, MONDO:0014562

## Endpoint

https://nanbyodata.jp/sparql

## `mondo_id_list`

```javascript
({mondo_id}) => {
  mondo_id = mondo_id.replace(/MONDO:/g, "MONDO_");
  return "obo:" + mondo_id;
}
```

## `result`

```sparql
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX mo: <http://med2rdf/ontology/medgen#>
PREFIX efo: <http://www.ebi.ac.uk/efo/>

SELECT DISTINCT
  str(?mondo_id) as ?mondo_id
  str(?mondo) as ?mondo_url
  str(?mondo_label_en) as ?mondo_label_en
  str(?mondo_label_ja) as ?mondo_label_ja
  str(?mondo_definition) as ?mondo_definition
  str(?medgen_concept) as ?medgen_concept
  str(?medgen_concept_id) as ?medgen_concept_id
  str(?medgen_concept_name) as ?medgen_concept_name
  str(?medgen_definition) as ?medgen_definition
  str(?orphanet) as ?orphanet_url
  str(?orphanet_id) as ?orphanet_id
  str(?orphanet_definition) as ?orphanet_definition
WHERE {
  VALUES ?mondo { {{mondo_id_list}} }

  GRAPH <https://nanbyodata.jp/rdf/ontology/mondo> {
    ?mondo oboInOwl:id ?mondo_id .

    OPTIONAL {
      ?mondo rdfs:label ?mondo_label_en .
      FILTER(LANG(?mondo_label_en) = "" || LANG(?mondo_label_en) = "en")
    }

    OPTIONAL {
      ?mondo rdfs:label ?mondo_label_ja .
      FILTER(LANG(?mondo_label_ja) = "ja")
    }

    OPTIONAL {
      ?mondo obo:IAO_0000115 ?mondo_definition .
    }

    OPTIONAL {
      ?mondo skos:exactMatch ?orphanet .
      FILTER(CONTAINS(STR(?orphanet), "http://www.orpha.net/ORDO/Orphanet_"))
      BIND(REPLACE(STR(?orphanet), "http://www.orpha.net/ORDO/Orphanet_", "ORPHA:") AS ?orphanet_id)
    }
  }

  OPTIONAL {
    GRAPH <https://nanbyodata.jp/rdf/ontology/ordo> {
      ?orphanet efo:definition ?orphanet_definition .
    }
  }

  OPTIONAL {
    GRAPH <https://nanbyodata.jp/rdf/medgen> {
      ?mgconso rdfs:seeAlso ?mondo ;
        dct:source mo:MONDO ;
        rdfs:label ?medgen_label .

      ?medgen_concept a mo:ConceptID ;
        mo:mgconso ?mgconso ;
        dct:identifier ?medgen_concept_id ;
        rdfs:label ?medgen_concept_name ;
        skos:definition ?medgen_definition .
    }
  }
}
ORDER BY ?mondo_id ?medgen_concept_id ?orphanet_id
```

## Output

```javascript
({result}) => {
  return result.results.bindings.map(data => {
    return Object.keys(data).reduce((obj, key) => {
      obj[key] = data[key].value;
      return obj;
    }, {});
  });
}
```
