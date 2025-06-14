# [PCF] Get PubChem data by GENE ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0012197
  * example: 0005835, 0004975, 0018096, 0007477
* `ncbi_gene_id` NCBI gene ID
  * default: 68964
  * example: 6710, 6521

## Endpoint
https://rdfportal.org/backend/pubchem/sparql

//https://rdfportal.org/pubchem/sparql

## `mondo_id_list`
```javascript
({ mondo_id }) =>
  'mondo:' + mondo_id.replace(/MONDO:/gi, '').trim().replace(/[\s,]+/g, ' mondo:');
```

## `ncbi_gene_id_list`
```javascript
({ncbi_gene_id}) =>
  'ncbigene:' + ncbi_gene_id.replace(/ncbigene:/gi, '').trim().replace(/[\s,]+/g, ' ncbigene:');
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncbigene: <http://identifiers.org/ncbigene:>
PREFIX mondo: <http://purl.obolibrary.org/obo/MONDO_>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX pcvocab: <http://rdf.ncbi.nlm.nih.gov/pubchem/vocabulary#>
PREFIX prism: <http://prismstandard.org/namespaces/basic/3.0/>

SELECT DISTINCT ?title ?identifier ?publicationName ?date
WHERE { 
  VALUES ?relatedMatch { {{mondo_id_list}} }
  VALUES ?ncbigene { {{ncbi_gene_id_list}} }

  ?disease skos:relatedMatch ?relatedMatch .

  ?gene rdfs:seeAlso ?ncbigene .
  ?gene <http://www.bioassayontology.org/bao#BAO_0002870> ?md5 .

  ?cooccurrence rdf:subject ?disease .
  ?cooccurrence rdf:object ?md5 .
  ?cooccurrence rdf:type sio:SIO_000983 . #gene-disease association
  
  GRAPH <http://rdf.ncbi.nlm.nih.gov/pubchem/reference> {
    ?ref pcvocab:discussesAsDerivedByTextMining ?md5 ;
         pcvocab:discussesAsDerivedByTextMining ?disease .

    ?ref dcterms:title ?title .
    ?ref dcterms:identifier ?identifier .
    ?ref prism:publicationName ?publicationName .
    ?ref dcterms:date ?date .

    #?ref prism:contentType  ?contentType .
    #?ref dcterms:source ?source .
  }
  
}
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