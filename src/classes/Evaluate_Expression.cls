public class Evaluate_Expression {
    public static final String open ='('; 
    public static final String close =')'; 
    public static String  evaluateBraces(String formula, Map<String, String> keyValueMap)
    {
        
    	System.debug(open+'op'+close);
        formula = formula.substringBetween(open, close);
        System.debug('formula::'+formula); 
        String resultant = evaluateExpression(formula, keyValueMap);
        System.debug('resultant::'+resultant);
        return resultant;
    }
    
    public static String evaluateExpression(String formula, Map<String, String> keyValueMap)
    {
        System.debug('formula::'+formula);
        if(formula.contains(open))
        {
            while(formula.contains(open))
            {
                String braceExp = formula.substringBetween(open, close);
                String res = evaluateBraces(formula, keyValueMap); 
                formula = formula.replace('('+braceExp+')', res);   
                System.debug('formula::'+formula);
            }
        }
        
        List<String> literals_temp = new List<String>();
        set<String> literals = new set<String>();
        if(formula.contains('+'))
        {
            //literals.addAll(formula.split('\\+'));
            literals_temp = split_Literals(formula.split('\\+'), '+');
            literals.addAll(literals_temp);
        }
        System.debug('literals::'+literals);
        if(formula.contains('-'))
        {
            literals_temp = split_Literals(formula.split('\\-'), '-');
            literals.addAll(literals_temp);
        }
        if(formula.contains('*'))
        {
            literals_temp = split_Literals(formula.split('\\*'), '*'); 
            literals.addAll(literals_temp);
        }
		System.debug('literals::'+literals);        
        if(formula.contains('/'))
        {
            literals_temp = split_Literals(formula.split('/'), '/');  
            literals.addAll(literals_temp);
        }
        System.debug('literals::'+literals);
        for(String s :literals)
        {
            System.debug(s);
            if(!s.contains('+') && !s.contains('-') && !s.contains('*') && !s.contains('/')
               && keyValueMap.containsKey(s.toLowerCase()))
            {
                String val = keyValueMap.get(s.toLowerCase());
                if(val == null){
                	val = '0';    
                }
                formula = formula.replaceAll(s, val);
            }    
        }
        System.debug(formula);
        decimal resultant = evaluate(formula);
        return String.valueOf(resultant);    
    }
    public static List<String> split_Literals(List<String> literals, String op)
    {
        List<String> literals_temp = literals;
        literals = new List<String>();
        for(String s : literals_temp)
        {
            literals.add(s);
            if(op != '/')
            {
             	literals.addAll(s.split('\\'+op+'\''));   
            }else{
            	literals.addAll(s.split('/'));    
            }
            
        }   
        return literals;
    }
    public static decimal evaluate(string tokens)
    {
        List<Integer> charIndex = new List<Integer>();
        List<Integer> tempcharIndex = new List<Integer>();
        List<String> operators = new List<String>();
        List<decimal> values = new List<decimal>();
        System.debug(tokens+'tokens length::'+tokens.length());
        for(Integer i = 0; i < tokens.length(); i++)
        { 
           	charIndex.clear();
            charIndex.add(tokens.charAt(i));
            String token = String.fromCharArray(charIndex);
            // Current token is a whitespace, 
            // skip it. 
            if(token == ' ') 
                continue; 
            if(token.isNumeric())
            { 
                decimal val = 0; 
                //2.5*2.5
                boolean hasDecimal = false;
                Integer precision = 1;
                while(i < tokens.length() &&  
                      token.isNumeric()) 
                { 
                    tempcharIndex.clear();
                    tempcharIndex.add(tokens.charAt(i));
                    String t = String.fromCharArray(tempcharIndex);
                    if(t == ','){
                    	system.debug('test'+ t); 
                        i++;
                        continue;
                    }
                    if(t.isNumeric())
                    {
                        System.debug('hasDecimal::'+hasDecimal); 
                        System.debug(val+'hasDecimal::'+t);
                        if(hasDecimal)
                        {
                            precision *=10;
                        	val += decimal.valueOf(t)/precision;     
                        }else{
                        	val = (val*10) + (Integer.valueOf(t));     
                        }
                        
                    }
                    else
                    {
                        if(t != '.')
                        {
                            operators.add(t);
                            break;    
                        }
                        else{
                            hasDecimal = true; 
                        }
                        
                    }
                    i++;
                    System.debug('val::'+val);
                } 
                
                System.debug('operators::'+operators);
                values.add(val); 
                
            } 
            
        } 
        decimal resultant = 0;
        System.debug('values::'+values);
        for(integer i=0; i<values.size(); i++)
        {
            if(i == 0)
            {
            	resultant = applyOp(resultant, values[i], '+');    
            }else{
            	resultant = applyOp(resultant, values[i], operators[i-1]);    
            }
        		    
        }
        return resultant.setScale(2);
    }
    public static decimal applyOp(decimal a, decimal b, String op){ 
        if(op == '+')
        {
         	return a+b;   
        }
        else if(op == '-')
        {
         	return a-b;   
        }
        else if(op == '*')
        {
         	return a*b;   
        }
        else if(op == '/')
        {
            if(b==0){
            	return 0;    
            }else{
           		return a/b;     
            }
               
        }else{
            return 0;
        }
            
    } 
}