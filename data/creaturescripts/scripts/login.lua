function onLogin(player)
	local serverName = configManager.getString(configKeys.SERVER_NAME)
	local loginStr = "Welcome to " .. serverName .. "!"
	if player:getLastLoginSaved() <= 0 then
		loginStr = loginStr .. " Please choose your outfit."
		player:sendOutfitWindow()
	else
		if loginStr ~= "" then
			player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)
		end

		---///OFFLINE MESSAGES///---
		local query = "SELECT `id`, `receiver`, `sender`, `message` FROM `offmsg` WHERE `receiver` = %s;"
		local messages = {}
		local msgQuery = db.storeQuery(string.format(query, db.escapeString(player:getName())))

		if msgQuery ~= false then
			repeat
				local id = result.getNumber(msgQuery, 'id')
				local receiver = result.getString(msgQuery, 'receiver')
				local sender = result.getString(msgQuery, 'sender')
				local msg = result.getString(msgQuery, 'message')
				local msgToSave = string.format("- %s: %s", sender, msg)
				table.insert(messages, {id = id, message = msgToSave})
			until not result.next(msgQuery)
		end

		result.free(msgQuery)

		if #messages > 0 then
			local messageText = "You have new messages:\n"
			for _, messageData in pairs(messages) do
				messageText = messageText .. messageData.message .. "\n"

				local messageId = messageData.id
				local deleteQuery = "DELETE FROM `offmsg` WHERE `id` = " .. messageId
				db.query(deleteQuery)
			end
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, messageText)
		end
			---///OFFLINE MESSAGES///---

		loginStr = string.format("Your last visit in %s: %s.", serverName, os.date("%d %b %Y %X", player:getLastLoginSaved()))
	end
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)

	-- Promotion
	local vocation = player:getVocation()
	local promotion = vocation:getPromotion()
	if player:isPremium() then
		local value = player:getStorageValue(PlayerStorageKeys.promotion)
		if value == 1 then
			player:setVocation(promotion)
		end
	elseif not promotion then
		player:setVocation(vocation:getDemotion())
	end

	-- Events
	player:registerEvent("PlayerDeath")
	player:registerEvent("DropLoot")
	return true
end
