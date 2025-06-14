# [PCF] pcf panel filter prioritize - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0010011 0043275
  * example: 0003847, 0018096, 0007477

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql
* 'https://dev-pubcasefinder.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({ mondo_id }) => 
  'mondo:MONDO_' + mondo_id.replace(/MONDO:/g, '').trim().replace(/[\s,]+/g, ' mondo:MONDO_');
```

## `expand_mondo` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>

#SELECT ?mondo_input (STR(?mondo_id) AS ?mondo) ?count
#SELECT (STR(?mondo_id) AS ?mondo)
SELECT ?mondo
WHERE {
  VALUES ?mondo_input { {{mondo_id_list}} }

  {
    SELECT ?mondo_input ?mondo (MIN(ABS(xsd:integer(?count) - 200)) AS ?min_diff)
    WHERE {
      ?mondo_input rdfs:subClassOf* ?sup .
      ?sup sio:SIO_001112 ?count ;
           oboInOwl:id ?mondo .
      FILTER(xsd:integer(?count) >= 200)
    }
    GROUP BY ?mondo_input ?mondo
  }

  {
    SELECT ?mondo_input (MIN(ABS(xsd:integer(?count) - 200)) AS ?min_diff_val)
    WHERE {
      ?mondo_input rdfs:subClassOf* ?sup .
      ?sup sio:SIO_001112 ?count .
      FILTER(xsd:integer(?count) >= 200)
    }
    GROUP BY ?mondo_input
  }

  FILTER(?min_diff = ?min_diff_val)
}
```

## `expand_mondo_list` get mondo uri
```javascript
({
  json({ expand_mondo }) {
    const rows = expand_mondo.results.bindings;
    const mondo_uris = rows.map(r => r.mondo ? r.mondo.value.replace('MONDO:', 'MONDO_') : 'NA');
    return 'mondo:' + mondo_uris.join(' mondo:');
  }
})
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT DISTINCT 
?gene_id
#?hgnc_gene_symbol
WHERE {
  {
    SELECT DISTINCT ?disease WHERE {
      VALUES ?mondo_list { {{expand_mondo_list}} }
      ?mondo_list <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_id .
      
      #?mondo_sub_tier rdfs:subClassOf* mondo:MONDO_{{mondo_id_list}} ;
      ?mondo_sub_tier rdfs:subClassOf* ?mondo_list ;
      skos:exactMatch ?exactMatch_disease .
      FILTER(CONTAINS(STR(?exactMatch_disease), "omim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
      BIND (IRI(replace(STR(?exactMatch_disease), 'http://identifiers.org/omim/', 'http://identifiers.org/mim/')) AS ?disease) .
    }
  }
  GRAPH <https://pubcasefinder.dbcls.jp/rdf/pcf> {
    ?as sio:SIO_000628 ?disease ;
         sio:SIO_000628 ?gene_uri .
	?disease rdf:type ncit:C7057 .
    ?gene_uri rdf:type ncit:C16612 ;
              dcterms:identifier ?gene_id ;
              sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] .
  }
}
```

## Output
```javascript
({ expand_mondo_list, result }) => ({ 
  [expand_mondo_list.replace(/mondo:MONDO_/gi, 'MONDO:').replace(/ /g, '|')]: 
    result.results.bindings.map(r => 'GENEID:' + r.gene_id.value) 
    //result.results.bindings.map(r => 'GENEID:' + r.hgnc_gene_symbol.value) 
});