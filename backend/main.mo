import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Float "mo:base/Float";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Result "mo:base/Result";
import Char "mo:base/Char";
import Iter "mo:base/Iter";

actor {
    private func base64Encode(input : [Nat8]) : Text {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        let alphabetArray = Iter.toArray(Text.toIter(alphabet));
        var output = "";
        let len = input.size();
        
        for (i in Iter.range(0, len - 1)) {
            if (i % 3 == 0) {
                let b1 : Nat8 = input[i];
                let b2 : Nat8 = if (i + 1 < len) input[i + 1] else 0;
                let b3 : Nat8 = if (i + 2 < len) input[i + 2] else 0;
                
                output := Text.concat(output, Text.fromChar(alphabetArray[Nat8.toNat(b1 >> 2)]));
                output := Text.concat(output, Text.fromChar(alphabetArray[Nat8.toNat(((b1 & 0x03) << 4) | (b2 >> 4))]));
                output := Text.concat(output, if (i + 1 < len) Text.fromChar(alphabetArray[Nat8.toNat(((b2 & 0x0F) << 2) | (b3 >> 6))]) else "=");
                output := Text.concat(output, if (i + 2 < len) Text.fromChar(alphabetArray[Nat8.toNat(b3 & 0x3F)]) else "=");
            };
        };
        output
    };

    public func processImage(imageData : [Nat8]) : async Result.Result<Text, Text> {
        let base64Image = base64Encode(imageData);
        
        let content = [
            {
                content_type = "text";
                text = "Analyze this image:";
            },
            {
                content_type = "image";
                source = {
                    content_type = "base64";
                    media_type = "image/jpeg";
                    data = base64Image;
                };
            }
        ];

        let systemPrompt = "You are an expert computer vision system. Analyze the provided image and return ONLY a JSON object containing bounding boxes. Be super precise and try to detect as many objects as possible. Follow these strict rules: 1. Output MUST be valid JSON with no additional text. 2. Each detected object must have: 'element' (descriptive name of the object), 'bbox' ([x1, y1, x2, y2] coordinates normalized 0-1), 'confidence' (confidence score 0-1). 3. Use this exact format: [{\"element\": \"object_name\", \"bbox\": [x1, y1, x2, y2], \"confidence\": 0.95}]. 4. Coordinates must be precise and properly normalized. 5. DO NOT include any explanation or additional text.";

        // TODO: Implement API call to Anthropic here
        Debug.print("API call to Anthropic would be made here with base64 image: " # base64Image);

        // Return a placeholder result for now
        #err("Anthropic API call not implemented")
    };
}
