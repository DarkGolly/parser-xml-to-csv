
require 'nokogiri'
require 'open-uri'
require 'pry'
require 'csv'

(1..20).each do |index|# перебераем все xml файлы, т.е. повторяем все действия ниже 20 раз

  doc = Nokogiri::XML(File.open("IA_Indvl_Feeds#{index}.xml"))#берем xml и помещаем в переменную

  headrs = %w(indvlPK last first orgPK org_name street1 street2 city state country zip state_reg exam_codes branch_street1 branch_street2 branch_city branch_state branch_zip branch_cntry)
  #в хидерс помещаем строу с именами с помощью %w говорим, что это массив и в каместве параметра передаём строку и отделяем слова пробелом
  CSV.open("IAR_Feed_#{index}.csv", "wb") do |csv|#создаём цсвшку с очередным индексом
    csv << headrs # в эту созданную цсвшку кидаем наш выше созданный массив через <<

    doc.xpath('//Indvl').each do |item|# перебераем все Indvl
      values = []
      info = item.xpath(".//Info").first #помещаем в переменную первое значение Info
      if !info.nil?#проверяем, если значение НЕ пустое, то выполняем блок кода
        values << info["indvlPK"].to_s#помещаем пустой массив значение поля indvlPK
        values << info["lastNm"].to_s#тут тоже самое что и выше только для поля lastNm
        values << info["firstNm"].to_s#тут так же
      end

      crnt_emp = item.xpath(".//CrntEmp").first#присваиваем переменной массив данных CrntEmp
      if !crnt_emp.nil? #проверяем, если значение НЕ пустое, то выполняем блок кода
        values << crnt_emp["orgPK"].to_s#дальше помещаем данные в массив
        values << crnt_emp["orgNm"].to_s#и т.д
        values << crnt_emp["str1"].to_s
        values << crnt_emp["str2"].to_s
        values << crnt_emp["city"].to_s
        values << crnt_emp["state"].to_s
        values << crnt_emp["cntry"].to_s
        values << crnt_emp["postlCd"].to_s
      end

      state_reg = item.xpath(".//CrntRgstn").map do |item| #присваиваем переменной результат возврата map - массив данных покорые он собрал ниже в переменную итем
        item["regAuth"]# тут собрал все значения поля regAuth в массив
      end
      values << state_reg.join(",")#помещаем в наш ранее созданный массив, массив state_reg и все значения через запятую

      exm_codes = item.xpath(".//Exm").map do |item|#присваиваем переменной результат возврата map - массив данных покорые он собрал ниже в переменную итем
        item["exmCd"]
      end
      values << exm_codes.join(",")#помещаем в наш ранее созданный массив, массив exm_codes и все значения через запятую
      #binding.pry
      item.xpath(".//CrntEmp//BrnchOfLoc").each do |branch|#перебераем все BrnchOfLoc
        branch_values = []
        branch_values << branch["str1"].to_s#помещаем в наш пустой массив найденые значения поля
        branch_values << branch["str2"].to_s# тут тоже самое только другое поле
        branch_values << branch["city"].to_s# ну и т.д.
        branch_values << branch["state"].to_s
        branch_values << branch["postlcd"].to_s
        branch_values << branch["cntry"].to_s
        row_values = values + branch_values #объеденяем наши массивы в единый массив
        csv << row_values #закидываем в цсвшку уже готовый массив с данными
      end
    end
  end
end# и так повторям 20 раз
