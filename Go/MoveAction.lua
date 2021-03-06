MoveAction = Class(FunctionAction)
function MoveAction.GetFactory(func)
	return function()
		return MoveAction.new(
			function(optional)
				local success, m = func()
				if not success and not optional then
					while not success do
						success, m = func()
						sleep(0)
					end
				end
				return success, m
			end
		)
	end
end
function MoveAction:constructor(func)
	FunctionAction.constructor(self, func)
	self.autoDigAtack = false
end

function MoveAction:run(invoc)
	local optional = invoc.optional or self.optional
	local success
	local i = 1
	local r

	while self.count == -1 or i <= self.count do
		local autoDig = Nav.autoDig
		local autoAttack = Nav.autoAttack

		if (optional) then
			Nav.autoDig = false
		end
		if (self.autoDigAttack) then
			Nav.autoDig = true
			Nav.autoAttack = true
		end
		r = self:call(ActionInvocation.new(optional, invoc.previousResult))
		Nav.autoDig = autoDig
		Nav.autoAttack = autoAttack

		success = r.success ~= self.invert

		if not success then
			if self.optional then
				return ActionResult.new(self, true, r.data)
			elseif optional then
				return ActionResult.new(self, false, r.data)
			else
				i = i - 1
			end
		end

		i = i + 1
	end

	return ActionResult.new(self, true ~= self.invert, r.data)
end
function MoveAction:mod(mod)
	if (FunctionAction.mod(self, mod)) then
		return true
	end

	if type(mod) == 'string' then
		if mod == '!' then
			self.autoDigAttack = true
			return true
		end
	end

	return false
end
