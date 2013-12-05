/*
ENG-0711-45
contains a map of accent characters to non-accent counterparts
test comment from Constantine's Github
*/
public class AccentCharactersMapping {
	public static Map<String, String> CHARACTER_MAP = new Map<String, String>();
	static {
        CHARACTER_MAP.put('À','A');
        CHARACTER_MAP.put('Á','A');
        CHARACTER_MAP.put('Â','A');
        CHARACTER_MAP.put('Ä','A');
        CHARACTER_MAP.put('Ã','A');
        CHARACTER_MAP.put('Å','A');
        CHARACTER_MAP.put('à','a');
        CHARACTER_MAP.put('á','a');
        CHARACTER_MAP.put('â','a');
        CHARACTER_MAP.put('ä','a');
        CHARACTER_MAP.put('ã','a');
        CHARACTER_MAP.put('å','a');
        CHARACTER_MAP.put('Æ','AE');
        CHARACTER_MAP.put('Ä','AE');
        CHARACTER_MAP.put('æ','ae');
        CHARACTER_MAP.put('ä','ae');
        CHARACTER_MAP.put('Ç','C');
        CHARACTER_MAP.put('ç','c');
        CHARACTER_MAP.put('Ð','D');
        CHARACTER_MAP.put('ð','d');
        CHARACTER_MAP.put('È','E');
        CHARACTER_MAP.put('É','E');
        CHARACTER_MAP.put('Ê','E');
        CHARACTER_MAP.put('Ë','E');
        CHARACTER_MAP.put('è','e');
        CHARACTER_MAP.put('é','e');
        CHARACTER_MAP.put('ê','e');
        CHARACTER_MAP.put('ë','e');
        CHARACTER_MAP.put('ƒ','f');
        CHARACTER_MAP.put('Ì','I');
        CHARACTER_MAP.put('Í','I');
        CHARACTER_MAP.put('Î','I');
        CHARACTER_MAP.put('Ï','I');
        CHARACTER_MAP.put('ì','i');
        CHARACTER_MAP.put('í','i');
        CHARACTER_MAP.put('î','i');
        CHARACTER_MAP.put('ï','i');
        CHARACTER_MAP.put('Ñ','N');
        CHARACTER_MAP.put('ñ','n');
        CHARACTER_MAP.put('Ò','O');
        CHARACTER_MAP.put('Ó','O');
        CHARACTER_MAP.put('Ô','O');
        CHARACTER_MAP.put('Ö','O');
        CHARACTER_MAP.put('Õ','O');
        CHARACTER_MAP.put('Ø','O');
        CHARACTER_MAP.put('ò','o');
        CHARACTER_MAP.put('ó','o');
        CHARACTER_MAP.put('ô','o');
        CHARACTER_MAP.put('ö','o');
        CHARACTER_MAP.put('õ','o');
        CHARACTER_MAP.put('ø','o');
        CHARACTER_MAP.put('Œ','OE');
        CHARACTER_MAP.put('Ö','O');
        CHARACTER_MAP.put('œ','oe');
        CHARACTER_MAP.put('ö','o');
        CHARACTER_MAP.put('Š','S');
        CHARACTER_MAP.put('š','s');
        CHARACTER_MAP.put('ß','ss');
        CHARACTER_MAP.put('Ù','U');
        CHARACTER_MAP.put('Ú','U');
        CHARACTER_MAP.put('Û','U');
        CHARACTER_MAP.put('Ü','U');
        CHARACTER_MAP.put('ù','u');
        CHARACTER_MAP.put('ú','u');
        CHARACTER_MAP.put('û','u');
        CHARACTER_MAP.put('ü','u');
        CHARACTER_MAP.put('Ü','UE');
        CHARACTER_MAP.put('ü','ue');
        CHARACTER_MAP.put('Ý','Y');
        CHARACTER_MAP.put('Ÿ','Y');
        CHARACTER_MAP.put('ÿ','y');
        CHARACTER_MAP.put('ý','y');
        CHARACTER_MAP.put('Ž','Z');
        CHARACTER_MAP.put('ž','z');
	}
    public static String replaceAccents(String str) {
    	boolean changed = false;
    	String localNameStr = '';
    	for (Integer i=0; i < str.length(); i++) {
    		String ch = str.substring(i, i+1);
    		String replacementCh = AccentCharactersMapping.CHARACTER_MAP.get(ch);
    		if ( replacementCh != null ) {
    			changed = true;
    			System.debug('Replacing character=' + ch + ' with ' + replacementCh);
    			ch = replacementCh;	
    		} 
    		localNameStr = localNameStr + ch;
    	}
    	System.debug('result localNameStr=' + localNameStr + ' str=' + str);
   		return localNameStr;
    }
}