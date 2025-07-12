# [PCF] Get GENE ID AND PAPER COUNT by MONDO ID NCBI GENE ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0005093
  * example: 0007254, 0007943, 0018096, 0007477

## Endpoint
https://rdfportal.org/backend/pubchem/sparql

//https://rdfportal.org/pubchem/sparql

## `mondo_id_list`
```javascript
({ mondo_id }) =>
  'mondo:' + mondo_id.replace(/MONDO:/gi, '').trim().replace(/[\s,]+/g, ' mondo:');
```

## `cooccurrence_gene` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX bao: <http://www.bioassayontology.org/bao#>
PREFIX mondo: <http://purl.obolibrary.org/obo/MONDO_>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX taxonomy: <http://rdf.ncbi.nlm.nih.gov/pubchem/taxonomy/>
SELECT DISTINCT ?cooccurrence ?gene_id WHERE {
  VALUES ?relatedMatch { {{mondo_id_list}} }
  GRAPH <http://rdf.ncbi.nlm.nih.gov/pubchem/disease> {
    ?disease skos:relatedMatch ?relatedMatch .
  }
  GRAPH <http://rdf.ncbi.nlm.nih.gov/pubchem/cooccurrence> {
    ?cooccurrence rdf:subject ?disease ;
                  rdf:object ?md5 ;
                  rdf:type sio:SIO_000983 .
  }
  GRAPH <http://rdf.ncbi.nlm.nih.gov/pubchem/gene> {
    ?gene bao:BAO_0002870 ?md5 ;
          up:organism taxonomy:TAXID9606 ;
          rdf:type sio:SIO_010035 .
    ?gene rdfs:seeAlso ?gene_id .
    FILTER (CONTAINS(STR(?gene_id), "http://identifiers.org/ncbigene:"))
  }
}
```

## `cooccurrence_id_list`
```javascript
({
  json({cooccurrence_gene}) {
    return cooccurrence_gene.results.bindings.map(row => {
      const uri = row.cooccurrence.value;
      const base = "http://rdf.ncbi.nlm.nih.gov/pubchem/cooccurrence/";
      if (uri.startsWith(base)) {
        return "pubchem:" + uri.slice(base.length);
      } else {
        throw new Error("Unexpected URI: " + uri);
      }
    }).join(" ");
  }
})

```

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql

## `result` 
```sparql
PREFIX ncbigene: <http://identifiers.org/ncbigene/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX mesh: <http://identifiers.org/mesh/>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX pubchem: <http://rdf.ncbi.nlm.nih.gov/pubchem/cooccurrence/>
SELECT DISTINCT ?cooccurrence_list ?count
WHERE {
  VALUES ?cooccurrence_list { {{cooccurrence_id_list}} }
  ?cooccurrence_list ?p ?count .
}
```

## Output
```javascript
({
  cooccurrence_gene, result
}) => {
  // 1. cooccurrence URI → gene_id 매핑 테이블 생성
  const cooccurrenceMap = {};
  cooccurrence_gene.results.bindings.forEach(row => {
    cooccurrenceMap[row.cooccurrence.value] = row.gene_id.value;
  });

  // 2. 결과 생성: cooccurrence URI에 해당하는 gene_id와 count 반환
  return result.results.bindings.map(row => {
    const uri = row.cooccurrence_list.value;
    const gene_id_full = cooccurrenceMap[uri];
    return {
      gene_id: gene_id_full
        ? gene_id_full.replace("http://identifiers.org/ncbigene:", "")
        : "UNKNOWN",
      count: row.count.value
    };
  });
}
```